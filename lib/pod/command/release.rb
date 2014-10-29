module Pod
  class Command
    # The pod plugins command.
    #
    class Release < Command
      # require 'pod/command/plugins/list'
      # require 'pod/command/plugins/search'
      # require 'pod/command/plugins/create'

      self.summary = 'Release podspecs in current directory'
      # self.description = <<-DESC
      #   Lists or searches the available CocoaPods plugins
      #   and show if you have them installed or not.
      #   Also allows you to quickly create a new Cocoapods
      #   plugin using a provided template.
      # DESC

      def run
        puts "It worked"
        # path = get_path_of_spec(@name)
        # spec = Specification.from_file(path)
        # UI.puts "Opening #{spec.name} documentation"
        # `open "http://cocoadocs.org/docsets/#{spec.name}"`
      end
    end
  end
end
