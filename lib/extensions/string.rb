#
# Ronin - A decentralized repository for the storage and sharing of computer
# security advisories, exploits and payloads.
#
# Copyright (c) 2007 Hal Brodigan (postmodern at users.sourceforge.net)
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

require 'scanf'
require 'base64'

class String

  def url_encode
    output = ''

    self.each_byte { |c| output+=sprintf("%%%X",c) }
    return output
  end

  def url_decode
    self.block_scanf('%%%X') { |c| input+=c[0].chr }.join
  end

  def html_dec_encode
    output = ''

    self.each_byte { |c| output+=sprintf("&#%d",c) }
    return output
  end

  def html_dec_decode
    self.block_scanf('&#%d') { |c| input+=c[0].chr }.join
  end

  def html_hex_encode
    output = ''

    self.each_byte { |c| output+=sprintf("&#%X;",c) }
    return output
  end

  def html_hex_decode
    self.block_scanf('&#%X;') { |c| input+=c[0].chr }.join
  end

  def base64_encode
    Base64.encode64(self)
  end

  def base64_decode
    Base64.decode64(self)
  end

end