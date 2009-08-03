require 'barby/outputter'
require 'im_magick'

module Barby


  # Generate image from barcodes using im_magick(http://github.com/fabien/im_magick)
  #
  class ImagickOutputter < Outputter
  
    register :to_image

    attr_accessor :height, :xdim, :ydim, :margin

    # Generate a image
    def to_image(filename, opts={})
      raise "Missing an image filename" if filename.nil? || filename.empty?

      with_options opts do
        cmd = ImMagick::convert do |m|
          m.filename = filename
          m.size = "#{full_width}x#{full_height}"
          m.canvas = :white
          m.fill = :black

          x = margin
          y = margin

          if barcode.two_dimensional?
            encoding.each do |line|
              line.split(//).map{|c| c == '1' }.each do |bar|
                m.draw "rectangle #{x},#{y} #{x+(xdim-1)}, #{y+(ydim-1)}" if bar
                x += xdim
              end
              x = margin
              y += ydim
            end
          else
            booleans.each do |bar|
              m.draw "rectangle #{x},#{y} #{x+(xdim-1)}, #{y+(height-1)}" if bar
              x += xdim
            end
          end

        end

        cmd.run.save filename
      end
    end


    #The height of the barcode in px
    #For 2D barcodes this is the number of "lines" * ydim
    def height
      barcode.two_dimensional? ? (ydim * encoding.length) : (@height || 100)
    end

    #The width of the barcode in px
    def width
      length * xdim
    end

    #Number of modules (xdims) on the x axis
    def length
      barcode.two_dimensional? ? encoding.first.length : encoding.length
    end

    #X dimension. 1X == 1px
    def xdim
      @xdim || 1
    end

    #Y dimension. Only for 2D codes
    def ydim
      @ydim || xdim
    end

    #The margin of each edge surrounding the barcode in pixels
    def margin
      @margin || 10
    end

    #The full width of the image. This is the width of the
    #barcode + the left and right margin
    def full_width
      width + (margin * 2)
    end

    #The height of the image. This is the height of the
    #barcode + the top and bottom margin
    def full_height
      height + (margin * 2)
    end


  end


end
