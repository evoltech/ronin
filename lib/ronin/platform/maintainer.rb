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

module Ronin
  module Platform
    class Maintainer

      # Name of the maintainer
      attr_reader :name

      # Email of the maintainer
      attr_reader :email

      #
      # Creates a new Maintainer object with the specified _name_ and the
      # given _email_.
      #
      def initialize(name,email=nil)
        @name = name
        @email = email
      end

      #
      # Returns the String form of the maintainer object.
      def to_s
        if @email
          return "#{@name} <#{@email}>"
        else
          return @name.to_s
        end
      end

      #
      # Inspects the maintainer object.
      #
      def inspect
        "#<#{self.class.name}: #{self}"
      end

    end
  end
end
