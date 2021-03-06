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

require 'ronin/model'

require 'dm-predefined'

module Ronin
  class License

    include Model
    include DataMapper::Predefined

    # Primary key
    property :id, Serial

    # License name
    property :name, String

    # Description of license
    property :description, Text

    # URL of the License document
    property :url, String

    # Validations
    validates_present :name, :description
    validates_is_unique :name

    #
    # Returns the name of the license as a String.
    #
    def to_s
      @name.to_s
    end

    #
    # Defines a new builtin License object of the specified _name_ and the
    # given _opts_. If block is given, it will be passed the newly created
    # License object.
    #
    # _options_ may contain the following keys:
    # <tt>:description</tt>:: The description of the license.
    # <tt>:url</tt>:: The URL to the license.
    #
    def self.define(name,options={})
      super(name.downcase.gsub(/[\s_\-]+/,'_'),options.merge(:name => name))
    end

    # Creative Commons Licenses
    define 'CC by',
           :description => 'Creative Commons Attribution v3.0 License',
           :url => 'http://creativecommons.org/licenses/by/3.0/'

    define 'CC by-sa',
           :description => 'Creative Commons Attribution-Share Alike v3.0 License',
           :url => 'http://creativecommons.org/licenses/by-sa/3.0/'

    define 'CC by-nd',
           :description => 'Creative Commons Attribution-No Derivative Works v3.0 License',
           :url => 'http://creativecommons.org/licenses/by-nd/3.0/'

    define 'CC by-nc',
           :description => 'Creative Commons Attribution-Noncommercial v3.0 License',
           :url => 'http://creativecommons.org/licenses/by-nc/3.0/'

    define 'CC by-nc-sa',
           :description => 'Creative Commons Attribution-Noncommercial-Share Alike v3.0 License',
           :url => 'http://creativecommons.org/licenses/by-nc-sa/3.0/'

    define 'CC by-nc-nd',
           :description => 'Creative Commons Attribution-Noncommercial-No Derivative Works v3.0 License',
           :url => 'http://creativecommons.org/licenses/by-nc-nd/3.0/'

    define 'CC0',
           :description => 'Creative Commons Zero License',
           :url => 'http://creativecommons.org/licenses/zero/1.0/'

    # GNU Public Licenses
    define 'GPL-2',
           :description => 'GNU Public License v2.0',
           :url => 'http://www.gnu.org/licenses/gpl-2.0.txt'

    define 'GPL-3',
           :description => 'GNU Public License v3.0',
           :url => 'http://www.gnu.org/licenses/gpl-3.0.txt'

    define 'LGPL-3',
           :description => 'GNU Lesser General Public License v3.0',
           :url => 'http://www.gnu.org/licenses/lgpl-3.0.txt'

    # The MIT Licence
    define 'MIT',
           :description => 'The MIT Licence',
           :url => 'http://www.opensource.org/licenses/mit-license.php'

  end
end
