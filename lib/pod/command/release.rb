module Pod
  class Command
    class Release < Command
      self.summary = 'Release podspecs in current directory'

      def execute(command, options = {})
        options = { :optional => false }.merge options

        puts "#{"==>".magenta} #{command}"
        abort unless (system(command) || options[:optional])
      end

      self.arguments = [
        CLAide::Argument.new('repository', false),
      ]

      def self.options
        [
          ['--allow-warnings', 'Allows push even if there are lint warnings'],
          ['--carthage', 'Validates project for carthage deployment'],
        ].concat(super.reject { |option, _| option == '--silent' })
      end

      def initialize(argv)
        warnings = argv.flag?('allow-warnings')
        @allow_warnings = warnings ? "--allow-warnings" : ""
        @repo = argv.shift_argument unless argv.arguments.empty?
        @carthage = argv.flag?('carthage')
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
          name = Specification.from_file(spec).name

          sources = SourcesManager.all.select { |r| r.name == "master" || r.url.start_with?("git") }
          sources = sources.select { |s| s.name == @repo } if @repo
          pushed_sources = []
          available_sources = SourcesManager.all.map { |r| r.name }

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
          execute "pod lib lint #{spec} #{@allow_warnings} --sources=#{available_sources.join(',')}"
          execute "pod lib lint #{spec} --use-libraries #{@allow_warnings} --sources=#{available_sources.join(',')}"

          if @carthage
            execute "carthage build --no-skip-current"
          end

          # TODO: create git tag for current version
          unless system("git tag | grep #{version} > /dev/null")
            execute "git add -A && git commit -m \"Releases #{version}.\"", :optional => true
            execute "git tag #{version}"
            execute "git push && git push --tags"
          end

          repo = @repo || pushed_sources.first.name
          if repo == "master"
            execute "pod trunk push #{spec} #{@allow_warnings}"
          else
            execute "pod repo push #{repo} #{spec} #{@allow_warnings}"
          end

          if @carthage && `git remote show origin`.include?("git@github.com")
            execute "carthage archive #{name}"

            user, repo = /git@github.com:(.*)\/(.*).git/.match(`git remote show origin`)[1, 2]
            file = "#{name}.framework.zip"

            create_release = %(github-release release --user #{user} --repo #{repo} --tag #{version} --name "Version #{version}" --description "Release of version #{version}")
            upload_release = %(github-release upload --user #{user} --repo #{repo} --tag #{version} --name "#{file}" --file "#{file}")

            if ENV['GITHUB_TOKEN'] && system("which github-release")
              execute create_release
              execute upload_release
              execute "rm #{file}"
            else
              puts "Run `#{create_release} --security-token XXX` to create a github release and"
              puts "    `#{upload_release} --security-token XXX` to upload to github releases"
            end
          end
        end
      end
    end
  end
end
