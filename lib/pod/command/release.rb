module Pod
  class Command
    class Release < Command
      self.summary = 'Release podspecs in current directory'

      def execute(command)
        puts "#{"==>".magenta} #{command}"
        abort unless system(command)
      end

      self.arguments = [
        CLAide::Argument.new('repository', false),
      ]

      def self.options
        [
          ['--allow-warnings', 'Allows push even if there are lint warnings'],
        ].concat(super.reject { |option, _| option == '--silent' })
      end

      def initialize(argv)
        warnings = argv.flag?('allow-warnings')
        @allow_warnings = warnings ? "--allow-warnings" : ""
        @repo = argv.shift_argument unless argv.arguments.empty?
        super
      end

      def run
        specs = Dir.entries(".").select { |s| s.end_with? ".podspec" }
        abort "No podspec found" unless specs.count > 0

        puts "#{"==>".magenta} updating repositories"
        SourcesManager.update

        for spec in specs
          name = spec.gsub(".podspec", "")
          version = Specification.from_file(spec).version

          sources = SourcesManager.all
          sources = sources.select { |s| s.name == @repo } if @repo
          pushed_sources = []

          abort "Please run #{"pod install".green} to continue" if sources.count == 0
          for source in sources
            pushed_versions = source.versions(name)
            next unless pushed_versions

            pushed_sources << source
            pushed_versions = pushed_versions.collect { |v| v.to_s }
            abort "#{name} (#{version}) has already been pushed to #{source.name}".red if pushed_versions.include? version.to_s
          end

          repo_unspecified = pushed_sources.count == 0 && sources.count > 1
          if repo_unspecified
            puts "When pushing a new podspec, please specify a repository to push #{name} to:"
            puts ""
            for source in sources
              puts "  * pod release #{source.name}"
            end
            puts ""
            abort
          end

          if pushed_sources.count > 1
            puts "#{name} has already been pushed to #{pushed_sources.join(', ')}. Please specify a repository to push #{name} to:"
            puts ""
            for source in sources
              puts "  * pod release #{source.name}"
            end
            puts ""
            abort
          end

          # verify lib
          execute "pod lib lint #{spec} #{@allow_warnings}"

          # TODO: create git tag for current version
          unless system("git tag | grep #{version} > /dev/null")
            execute "git add -A && git commit -m \"Releases #{version}.\""
            execute "git tag #{version}"
            execute "git push && git push --tags"
          end

          repo = pushed_sources.first.name
          if repo == "master"
            execute "pod trunk push #{spec} #{@allow_warnings}"
          else
            execute "pod repo push #{repo} #{spec} #{@allow_warnings}"
          end
        end
      end
    end
  end
end
