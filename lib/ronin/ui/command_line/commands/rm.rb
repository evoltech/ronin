#
#--
# Ronin - A Ruby platform designed for information security and data
# exploration tasks.
#
# Copyright (c) 2006-2009 Hal Brodigan (postmodern.mod3 at gmail.com)
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
#++
#

require 'ronin/ui/command_line/command'
require 'ronin/platform/overlay'

module Ronin
  module UI
    module CommandLine
      class RemoveCommand < Command

        def initialize
          @cache = nil
          @verbose = false

          super()
        end

        def define_options(opts)
          opts.usage = 'NAME [...] [options]'

          opts.options do
            opts.on('-C','--cache DIR','Specify an alternate overlay cache') do |dir|
              @cache = dir
            end

            opts.on('-v','--verbose','Enable verbose output') do
              @verbose = true
            end
          end

          opts.arguments(
            'NAME' => 'The overlay to remove'
          )

          opts.summary('Remove the specified repositories')
        end

        def arguments(*args)
          Platform.load_overlays(@cache) if @cache

          args.each do |name|
            Platform.remove(name) do |overlay|
              puts "Removing #{overlay.name.dump} ..."
            end
          end
        end

      end
    end
  end
end