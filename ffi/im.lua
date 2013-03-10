local ffi = require("ffi")

local libs = ffi_im_libs or {
    Windows = { x86 = "no Windows libIM yet", x64 = "no Windows libIM yet" },
    OSX = { x86 = "bin/OSX/libim.dylib", x64 = "bin/OSX/libim.dylib" },
    Linux = { x86 = "no Linux libIM yet", x64 = "no Linux libIM yet" }
}

local im = ffi.load(ffi_im_lib or libs[ ffi.os ][ ffi.arch ] or "im")

ffi.cdef [[
/** Image data type descriptors.
 * See also \ref datatypeutl.
 * \ingroup imagerep */
enum imDataType
{
  IM_BYTE,   /**< "unsigned char". 1 byte from 0 to 255.                  */
  IM_SHORT,  /**< "short". 2 bytes from -32,768 to 32,767.                */
  IM_USHORT, /**< "unsigned short". 2 bytes from 0 to 65,535.             */
  IM_INT,    /**< "int". 4 bytes from -2,147,483,648 to 2,147,483,647.    */
  IM_FLOAT,  /**< "float". 4 bytes single precision IEEE floating point.  */
  IM_CFLOAT  /**< complex "float". 2 float values in sequence, real and imaginary parts.   */
};

/** Image color mode color space descriptors (first byte). \n
 * See also \ref colormodeutl.
 * \ingroup imagerep */
enum imColorSpace
{
  IM_RGB,    /**< Red, Green and Blue (nonlinear).              */
  IM_MAP,    /**< Indexed by RGB color map (data_type=IM_BYTE). */
  IM_GRAY,   /**< Shades of gray, luma (nonlinear Luminance), or an intensity value that is not related to color. */
  IM_BINARY, /**< Indexed by 2 colors: black (0) and white (1) (data_type=IM_BYTE).     */
  IM_CMYK,   /**< Cian, Magenta, Yellow and Black (nonlinear).                          */
  IM_YCBCR,  /**< ITU-R 601 Y'CbCr. Y' is luma (nonlinear Luminance).                   */
  IM_LAB,    /**< CIE L*a*b*. L* is Lightness (nonlinear Luminance, nearly perceptually uniform). */
  IM_LUV,    /**< CIE L*u*v*. L* is Lightness (nonlinear Luminance, nearly perceptually uniform). */
  IM_XYZ     /**< CIE XYZ. Linear Light Tristimulus, Y is linear Luminance.             */
};

/** Image color mode configuration/extra descriptors (1 bit each in the second byte). \n
 * See also \ref colormodeutl.
 * \ingroup imagerep */
enum imColorModeConfig
{
  IM_ALPHA    = 0x100,  /**< adds an Alpha channel */
  IM_PACKED   = 0x200,  /**< packed components (rgbrgbrgb...) */
  IM_TOPDOWN  = 0x400   /**< orientation from top down to bottom */
};



/** File Access Error Codes
 * \par
 * In Lua use im.ErrorStr(err) to convert the error number into a string.
 * \ingroup file */
enum imErrorCodes	
{
  IM_ERR_NONE,     /**< No error. */
  IM_ERR_OPEN,     /**< Error while opening the file (read or write). */
  IM_ERR_ACCESS,   /**< Error while accessing the file (read or write). */
  IM_ERR_FORMAT,   /**< Invalid or unrecognized file format. */
  IM_ERR_DATA,     /**< Invalid or unsupported data. */
  IM_ERR_COMPRESS, /**< Invalid or unsupported compression. */
  IM_ERR_MEM,      /**< Insuficient memory */
  IM_ERR_COUNTER   /**< Interrupted by the counter */
};

/** \brief Image File Structure (Private).
 * \ingroup file */
typedef struct _imFile imFile;

int imFileReadImageInfo(imFile* ifile, int index, int *width, int *height, int *file_color_mode, int *file_data_type);

typedef struct _imImage
{
  /* main parameters */
  int width;          /**< Number of columns. image:Width() -> width: number [in Lua 5]. */
  int height;         /**< Number of lines. image:Height() -> height: number [in Lua 5]. */
  int color_space;    /**< Color space descriptor. See also \ref imColorSpace. image:ColorSpace() -> color_space: number [in Lua 5]. */
  int data_type;      /**< Data type descriptor. See also \ref imDataType. image:DataType() -> data_type: number [in Lua 5]. */
  int has_alpha;      /**< Indicates that there is an extra channel with alpha. image:HasAlpha() -> has_alpha: boolean [in Lua 5]. \n
                           It will not affect the secondary parameters, i.e. the number of planes will be in fact depth+1. \n
                           It is always 0 unless imImageAddAlpha is called. Alpha is automatically added in image loading functions. */

  /* secondary parameters */
  int depth;          /**< Number of planes                      (ColorSpaceDepth)   image:Depth() -> depth: number [in Lua 5].       */
  int line_size;      /**< Number of bytes per line in one plane (width * DataTypeSize)    */
  int plane_size;     /**< Number of bytes per plane.            (line_size * height)      */
  int size;           /**< Number of bytes occupied by the image (plane_size * depth)      */
  int count;          /**< Number of pixels per plane            (width * height)          */

  /* image data */
  void** data;        /**< Image data organized as a 2D matrix with several planes.   \n
                           But plane 0 is also a pointer to the full data.            \n
                           The remaining planes are: data[i] = data[0] + i*plane_size \n
                           In Lua, data indexing is possible using: image[plane][row][column] */

  /* image attributes */
  long *palette;      /**< Color palette. image:GetPalette() -> palette: imPalette [in Lua 5]. \n
                           Used only when depth=1. Otherwise is NULL. */
  int palette_count;  /**< The palette is always 256 colors allocated, but can have less colors used. */

  void* attrib_table; /**< in fact is an imAttribTable, but we hide this here */
} imImage;

imImage* imFileImageLoad(const char* file_name, int index, int *error);

void imImageDestroy(imImage* image);

]]

return im
