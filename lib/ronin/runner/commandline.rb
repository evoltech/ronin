#
# Ronin - A ruby development environment designed for information security
# and data exploration tasks.
#
# Copyright (c) 2006-2007 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/commands/command'
require 'ronin/commands/options'
require 'ronin/repo/cache'
require 'ronin/ronin'
require 'ronin/version'

require 'optparse'
require 'ostruct'

module Ronin
  module Commands
    class CommandLine

      # Registered commands
      attr_reader :commands

      def initialize
        @commands = []
        @command_names = {}

        register_command('install') { |argv| install(argv) }
        register_command('add') { |argv| add(argv) }
        register_command('list','ls') { |argv| list(argv) }
        register_command('update','up') { |argv| update(argv) }
        register_command('uninstall') { |argv| uninstall(argv) }
        register_command('help') { |argv| help(argv) }
      end

      def register_command(*names,&block)
        new_command = Command.new(*names,&block)
        @commands << new_command
        for name in names
          @command_names[name.to_s] = new_command
        end
      end

      def has_command?(name)
        @command_names.has_key?(name.to_s)
      end

      def get_command(name)
        @command_names[name.to_s]
      end

      def help_command(name)
        unless has_command?(name)
          puts "ronin: unknown command '#{name}'"
          return
        end

        get_command(name).run('--help')
      end

      def is_flag?(arg)
        return false unless arg
        return arg[0..0]=='-'
      end

      def is_argument?(arg)
        return false unless arg
        return arg[0..0]!='-'
      end

      def run(args=[])
        if (args.empty? || is_flag?(args[0]))
          return default(args)
        end

        sub_command = args.shift

        if (cmd = get_command(sub_command))
          return cmd.run(args)
        end

        # Initialize the object cache
        Ronin.load_object_cache

        # Load the application
        app = Repo.cache.application(sub_command)

        # Execute method of the application
        app.setup

        if (args.empty? || is_flag?(args[0]))
          app.main(args)
        else
          name = args.shift

          if (name!='setup' && name!='teardown')
            app.distribute_call(name)
          end
        end

        app.teardown
      end

      def default(argv=[])
        options = Options.new("ronin","[<sub-command>] [options]") do |options|
          options.version_option { version }
          options.help_option do
            help
            exit
          end
        end

        help if options.parse(argv).empty?
      end

      def install(argv=[])
        options = Options.comand("ronin","install","PATH [PATH ...] [options]") do |options|
          options.specific do
            options.option("--install-dir","Specify directory to install the repository in") do |path|
              options.path = path
            end
          end

          options.common do
            options.option("-C","--cache","Specify alternant location of repository cache") do |cache|
              Repo.load_cache(cache)
            end

            options.option("-v","--[no]-verbose","Run verbosely") do
              options.verbose = true
            end
          end

          options.arguments do
            arg("PATH","add the repository located at the specified PATH")
          end

          options.summary("Add a local repository located at the specified PATH to the repository cache")
        end

        options.parse(argv).each do |arg|
          Repo::RepositoryMetadata.new(arg) do |metadata| 
            if options.path
              Repo.cache.install(metadata,options.path)
            else
              Repo.cache.install(metadata)
            end
          end
        end
      end

      def add(argv=[])
        options = Options.sub_command("ronin","add","PATH [PATH ...] [options]") do |options|
          options.specific do
            options.option("-C","--cache","Specify alternant location of repository cache") do |cache|
              Repo.load_cache(cache)
            end

            options.verbose_option
            options.help_option
          end

          options.arguments do
            arg("PATH","add the repository located at the specified PATH")
          end

          options.summary("Add a local repository located at the specified PATH to the repository cache")
        end

        options.parse(argv).each { |path| Repo.cache.add(path) }

        Repo.cache.save
      end

      def list(argv=[])
        options = Options.sub_command("ronin","list","[NAME] [options]") do |options|
          options.common do
            options.option("-C","--cache","Specify alternant location of repository cache") do |cache|
              Repo.load_cache(cache)
            end

            options.verbose_option
            options.help_option
          end

          options.arguments do
            arg("NAME","name of the repository to display")
          end

          options.summary("Display the repository specified by NAME or all repositories in the cache")
        end

        arguments = options.parse(argv)
        unless arguments.empty?
          repo = Repo.cache.get_repository(arguments[0])

          puts "[ #{repo} ]"
          puts "\tname: #{repo.name}"
          puts "\tpath: #{repo.path}"
          puts "\ttype: #{repo.type}"

          if options.verbose
            repo.author.each_value do |author|
              puts "\n\tauthor: #{author.name}\n"

              author.contacts.each do |key,value|
                puts "\t\t#{key}: #{value}"
              end

              if author.biography
                puts "\t\tbiography:\n\n\t\t\t#{author.biography}"
              end

              putc "\n"
            end

            if repo.description
              puts "\tdescription:\n\n\t\t#{repo.description}"
            end
          end

          unless repo.deps.empty?
            puts "\n\tdependencies:\n\n"

            repo.deps.each_key do |dep|
              print "\t\t#{dep}"

              unless Repo.cache.has_repository?(dep)
                print " (missing)"
              end
              putc "\n"
            end
            putc "\n"
          end

          if (options.verbose && !(repo.categories.empty?))
            puts "\tapplications:\n\n"
            repo.applications.each { |app| puts "\t\t#{app}" }
          end
        else
          Repo.cache.repositories.each_value { |repo| puts repo }
        end
      end

      def update(argv=[])
        options = Options.sub_command("ronin","update","[NAME ...] [options]") do |options|
          options.specific do
            options.option("-C","--cache","Specify alternant location of repository cache") do |cache|
              Repo.load_cache(cache)
            end

            options.verbose_option
            options.help_option
          end

          options.arguments do
            arg("NAME","the name of the repository to update")
          end

          options.summary("Updates the repositories specified by NAME or all repositories in the cache")
        end

        arguments = opts.parse(argv)
        unless arguments.empty?
          arguments.each do |repo|
            Repo.cache.get_repository(repo).update
          end
        else
          Repo.cache.update
        end
      end

      def uninstall(argv)
        options = Options.sub_command("ronin","uninstall","NAME [NAME ...] [options]") do |options|
          options.specific do
            options.option("-C","--cache","Specify alternant location of repository cache") do |cache|
              Repo.load_cache(cache)
            end

            options.verbose_option
            options.help_option
          end

          options.argument do
            arg("NAME","name of epository to unistall")
          end

          options.summary("Uninstalls the repositories specified by NAME from the cache")
        end

        arguments = opts.parse(argv)
      end

      def help(argv=[])
        options = Options.sub_command("ronin","help","[sub-command ...]") do |options|
          options.specific do
            options.version { version }
            options.verbose_option
            options.help_option
          end
        end

        arguments = options.parse(argv)
        unless arguments.empty?
          arguments.each { |arg| help_command(arg) }
        else
          puts <<-end_usage
usage: ronin <sub-command> [options]

Available sub-commands:
end_usage
          @commands.each { |cmd| puts "  #{cmd}" }
        end
      end

      def version
        puts "ronin v#{Ronin::RONIN_VERSION}"
        exit
      end

    end
  end
end