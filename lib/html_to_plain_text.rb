# coding: utf-8

# Heaily adapted from Premailer: https://github.com/alexdunae/premailer
# Premailer License
# Copyright (c) 2007-2012, Alex Dunae.  All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# * Neither the name of Premailer, Alex Dunae nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'htmlentities'

module HtmlToPlainText

  # Returns the text in UTF-8 format with all HTML tags removed
  #
  # TODO: add support for OL
  def convert_to_text(html, line_length = 65, from_charset = 'UTF-8')
    
    # The gsubs will fail if html is a SafeBuffer, so we 
    # have to convert it to an actual String object.
    # http://makandracards.com/makandra/11171-how-to-fix-gsub-on-safebuffer-objects
    txt = html.to_str

    # to_str may or may not have created a new string
    # Ensure it here, since we will be modifying it in place.
    txt = txt.dup if txt.equal? html

    # remove head tag
    txt.gsub!(/<head.*<\/head>/mi, '')

    # remove linefeeds (\r\n and \r and \n)
    txt.gsub!(/[\r\n]/, ' ')

    # replace image by their alt attribute
    txt.gsub!(/<img.+?alt=\"([^\"]*)\"[^>]*\/>/i, '\1')
    txt.gsub!(/<img.+?alt='([^\']*)\'[^>]*\/>/i, '\1')

    # links
    txt.gsub!(/<a.+?href=\"([^\"]*)\"[^>]*>(.+?)<\/a>/i) do |s|
      $2.strip + ' (' + $1.strip + ')'
    end

    txt.gsub!(/<a.+?href='([^\']*)\'[^>]*>(.+?)<\/a>/i) do |s|
      $2.strip + ' (' + $1.strip + ')'
    end


    # handle headings (H1-H6)
    txt.gsub!(/(<\/h[1-6]>)/i, "\n\\1") # move closing tags to new lines
    txt.gsub!(/[\s]*<h([1-6]+)[^>]*>[\s]*(.*)[\s]*<\/h[1-6]+>/i) do |s|
      hlevel = $1.to_i

      htext = $2
      htext.gsub!(/<br[\s]*\/?>/i, "\n") # handle <br>s
      htext.gsub!(/<\/?[^>]*>/i, '') # strip tags

      # determine maximum line length
      hlength = 0
      htext.each_line { |l| llength = l.strip.length; hlength = llength if llength > hlength }
      hlength = line_length if hlength > line_length

      case hlevel
        when 1   # H1, asterisks above and below
          htext = ('*' * hlength) + "\n" + htext + "\n" + ('*' * hlength)
        when 2   # H1, dashes above and below
          htext = ('-' * hlength) + "\n" + htext + "\n" + ('-' * hlength)
        else     # H3-H6, dashes below
          htext = htext + "\n" + ('-' * hlength)
      end

      "\n\n" + htext + "\n\n"
    end

    # wrap spans
    txt.gsub!(/(<\/span>)[\s]+(<span)/mi, '\1 \2')

    # lists -- TODO: should handle ordered lists
    txt.gsub!(/[\s]*(<li[^>]*>)[\s]*/i, '* ')
    # list not followed by a newline
    txt.gsub!(/<\/li>[\s]*(?![\n])/i, "\n")

    # definition terms should be followed by a newline
    txt.gsub!(/<\/dt>[\s]*(?![\n])/i, "\n")

    # definitions should start with two spaces and end with a newline
    txt.gsub!(/(<dd[^>]*>)[\s]*/i, '-  ')
    txt.gsub!(/<\/dd>[\s]*(?![\n])/i, "\n")

    # definition lists should end with a line break
    txt.gsub!(/<\/dl>/i, "\n\n")

    # paragraphs and line breaks
    txt.gsub!(/<\/p>/i, "\n\n")
    txt.gsub!(/<br[\/ ]*>/i, "\n")

    # strip remaining tags
    txt.gsub!(/<\/?[^>]*>/, '')

    txt = word_wrap(txt, line_length)
    
    # strip extra spaces
    txt.gsub!(/\302\240+/, " ") # non-breaking spaces -> spaces
    txt.gsub!(/\n[ \t]+/, "\n") # space at start of lines
    txt.gsub!(/[ \t]+\n/, "\n") # space at end of lines

    # no more than two consecutive newlines
    txt.gsub!(/[\n]{3,}/, "\n\n")

    # no more than two consecutive spaces
    txt.gsub!(/ {2,}/, " ")
    
    # the word wrap messes up the parens
    # txt.gsub!(/\(\n(http[^)]+)\n\)/) do |s|
    #   "\n( " + $1 + " )\n"
    # end
    # txt.gsub!(/\(\n(http[^)]+)\)/) do |s|
    #   "\n( " + $1 + " )"
    # end
    # txt.gsub!(/\((http[^)]+)\n\)/) do |s|
    #   "( " + $1 + " )\n"
    # end

    txt.lstrip!

    # decode HTML entities
    txt = HTMLEntities.new.decode(txt)

    txt << "\n" unless txt.last == "\n"

    txt
  end

  # Taken from Rails' word_wrap helper (http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-word_wrap)
  def word_wrap(txt, line_length)
    txt.split("\n").collect do |line|
      line.length > line_length ? line.gsub(/(.{1,#{line_length}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end
end
