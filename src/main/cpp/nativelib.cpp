#include <jni.h>
#include <string>
#include <android/log.h>
#include "Magick++.h"
#include "native_debug.h"
#include <png.h>
#include <zlib.h>
#include <jpeglib.h>
#include <jerror.h>

using namespace std;
using namespace Magick;

std::uint32_t color_to_int(unsigned char A, unsigned char R, unsigned char G, unsigned char B) {
    return (A << 24) | (R << 16) | (G << 8) | B;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_nativelib_NativeLib_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

extern "C"
JNIEXPORT jintArray JNICALL
Java_com_example_nativelib_NativeLib_readPng(JNIEnv *env, jobject thiz, jstring path) {

    const char *filename = env->GetStringUTFChars(path, 0);
    LOGI("AAA processImage %s", filename);

    const char *libZlibVersion = zlibVersion();
    LOGI("AAA zlib %s", libZlibVersion);

    const char *pngVersion = png_get_libpng_ver(NULL);
    LOGI("AAA pngVersion %s", pngVersion);

    // Open the PNG file
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        LOGI("AAA Error opening file: ");
        return NULL;
    }

    // Create PNG read struct
    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png) {
        LOGI("AAA Error creating PNG read struct");
        fclose(fp);
        return NULL;
    }

    // Create PNG info struct
    png_infop info = png_create_info_struct(png);
    if (!info) {
        LOGI("AAA Error creating PNG info struct");
        png_destroy_read_struct(&png, NULL, NULL);
        fclose(fp);
        return NULL;
    }

    // Set up error handling
    if (setjmp(png_jmpbuf(png))) {
        LOGI("AAA Error during PNG read");
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        return NULL;
    }

    // Initialize the PNG reader
    png_init_io(png, fp);

    // Read the PNG header and get image information
    png_read_info(png, info);
    int width = png_get_image_width(png, info);
    int height = png_get_image_height(png, info);
    png_byte color_type = png_get_color_type(png, info);
    png_byte bit_depth = png_get_bit_depth(png, info);

    // Ensure the image is in RGBA format
    if (color_type != PNG_COLOR_TYPE_RGBA) {
        LOGI("AAA Only RGBA PNG images are supported");
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        return NULL;
    }

    // Allocate memory for the image data
    png_bytep *row_pointers = new png_bytep[height];
    for (int y = 0; y < height; y++) {
        row_pointers[y] = new png_byte[png_get_rowbytes(png, info)];
    }

    // Read the image data
    png_read_image(png, row_pointers);

    int size = width * height;
    jintArray items = env->NewIntArray(size);
    jint *pixels = (jint *) malloc(size * sizeof(jint));

    // Process each pixel in the image
    for (int y = 0; y < height; y++) {
        png_bytep row = row_pointers[y];
        for (int x = 0; x < width; x++) {
            png_bytep px = &(row[x * 4]);  // Each pixel has 4 bytes (RGBA)

            // Retrieve the color values
            png_byte alpha = px[3];
            png_byte red = px[0];
            png_byte green = px[1];
            png_byte blue = px[2];

            // Print the color values
            int pixel = color_to_int(alpha, red, green, blue);
            int index = y * width + x;
            pixels[index] = pixel;
        }
    }

    // Clean up resources
    for (int y = 0; y < height; y++) {
        delete[] row_pointers[y];
    }
    delete[] row_pointers;

    png_destroy_read_struct(&png, &info, NULL);
    fclose(fp);

    env->SetIntArrayRegion(items, 0, size, pixels);
    env->ReleaseStringUTFChars(path, filename);
    ::free(pixels);
    return items;
}

struct ImageData {
    unsigned char *pixels;
    int width;
    int height;
    int numChannels;
};

ImageData do_read_JPEG_file(struct jpeg_decompress_struct *cinfo, const char *filename) {
    /* We use our private extension JPEG error handler.
    * Note that this struct must live as long as the main JPEG parameter
    * struct, to avoid dangling-pointer problems.
    */
    ImageData result;
    struct jpeg_error_mgr jerr;
    /* More stuff */
    FILE *infile;                 /* source file */
//    JSAMPARRAY buffer;            /* Output row buffer */
    int row_stride;               /* physical row width in output buffer */

    if ((infile = fopen(filename, "rb")) == NULL) {
        LOGI("can't open %s", filename);
        return result;
    }
    /* Step 1: allocate and initialize JPEG decompression object */
    /* We set up the normal JPEG error routines, then override error_exit. */
    cinfo->err = jpeg_std_error(&jerr);

    /* Now we can initialize the JPEG decompression object. */
    jpeg_create_decompress(cinfo);

    /* Step 2: specify data source (eg, a file) */

    jpeg_stdio_src(cinfo, infile);

    /* Step 3: read file parameters with jpeg_read_header() */

    (void) jpeg_read_header(cinfo, TRUE);
    /* We can ignore the return value from jpeg_read_header since
     *   (a) suspension is not possible with the stdio data source, and
     *   (b) we passed TRUE to reject a tables-only JPEG file as an error.
     * See libjpeg.txt for more info.
     */

    /* Step 4: set parameters for decompression */

    /* In this example, we don't need to change any of the defaults set by
     * jpeg_read_header(), so we do nothing here.
     */

    /* Step 5: Start decompressor */

    (void) jpeg_start_decompress(cinfo);
    /* We can ignore the return value since suspension is not possible
     * with the stdio data source.
     */

    /* We may need to do some setup of our own at this point before reading
       * the data.  After jpeg_start_decompress() we have the correct scaled
       * output image dimensions available, as well as the output colormap
       * if we asked for color quantization.
       * In this example, we need to make an output work buffer of the right size.
       */
    /* JSAMPLEs per row in output buffer */
    row_stride = cinfo->output_width * cinfo->output_components;
    /* Make a one-row-high sample array that will go away when done with image */
//    buffer = (*cinfo->mem->alloc_sarray)
//            ((j_common_ptr) cinfo, JPOOL_IMAGE, row_stride, 1);

    // Retrieve image information
    int width = cinfo->output_width;
    int height = cinfo->output_height;
    int numChannels = cinfo->output_components;  // 3 for RGB, 1 for grayscale

    // Allocate memory for pixel data
    unsigned char *imageBuffer = new unsigned char[width * height * numChannels];


    /* Step 6: while (scan lines remain to be read) */
    /*           jpeg_read_scanlines(...); */

    /* Here we use the library's state variable cinfo->output_scanline as the
     * loop counter, so that we don't have to keep track ourselves.
     */
    while (cinfo->output_scanline < cinfo->output_height) {
        /* jpeg_read_scanlines expects an array of pointers to scanlines.
         * Here the array is only one element long, but you could ask for
         * more than one scanline at a time if that's more convenient.
         */

        unsigned char *row = imageBuffer + (cinfo->output_scanline * width * numChannels);

        (void) jpeg_read_scanlines(cinfo, &row, 1);

//        jpeg_read_scanlines(cinfo, buffer, 1);
//
//         Process each pixel in the scanline
//        for (int x = 0; x < width; x++) {
//             Retrieve the color values
//            int red = buffer[0][numChannels * x];
//            int green = buffer[0][numChannels * x + 1];
//            int blue = buffer[0][numChannels * x + 2];
//
//             Print the color values
//            LOGI("AAA jpeg Pixel at (%d,%d): ", x, cinfo->output_scanline - 1);
//            LOGI("AAA jpeg Red=%d Green=%d Blue=%d", red, green, blue);
//        }
        /* Assume put_scanline_someplace wants a pointer and sample count. */
//        put_scanline_someplace(buffer[0], row_stride);
    }

    /* Step 7: Finish decompression */

    (void) jpeg_finish_decompress(cinfo);
    /* We can ignore the return value since suspension is not possible
    * with the stdio data source.
    */

    /* Step 8: Release JPEG decompression object */

    /* This is an important step since it will release a good deal of memory. */
    jpeg_destroy_decompress(cinfo);

    /* After finish_decompress, we can close the input file.
     * Here we postpone it until after no more JPEG errors are possible,
     * so as to simplify the setjmp error logic above.  (Actually, I don't
     * think that jpeg_destroy can do an error exit, but why assume anything...)
     */
    fclose(infile);

    LOGI("JPEG READ COMPLETE");

    result.width = width;
    result.height = height;
    result.pixels = imageBuffer;
    result.numChannels = numChannels;
    return result;
}


extern "C"
JNIEXPORT jintArray JNICALL
Java_com_example_nativelib_NativeLib_readJpeg(JNIEnv *env, jobject thiz, jstring path) {
    const char *filePath = env->GetStringUTFChars(path, 0);
    LOGI("AAA readJpeg %s", filePath);

    /* This struct contains the JPEG decompression parameters and pointers to
    * working space (which is allocated as needed by the JPEG library).
    */
    struct jpeg_decompress_struct cinfo;

    ImageData imageData = do_read_JPEG_file(&cinfo, filePath);
    int width = imageData.width;
    int height = imageData.height;
    int numChannels = imageData.numChannels;

    int size = width * height;
    jintArray items = env->NewIntArray(size);
    jint *pixels = (jint *) malloc(size * sizeof(jint));

    // Access pixel values (assuming RGB image)
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int baseIndex = (y * width + x) * numChannels;
            unsigned char red = imageData.pixels[baseIndex];
            unsigned char green = imageData.pixels[baseIndex + 1];
            unsigned char blue = imageData.pixels[baseIndex + 2];

            int pixel = color_to_int(255, red, green, blue);
            int index = y * width + x;
            pixels[index] = pixel;
        }
    }

    env->SetIntArrayRegion(items, 0, size, pixels);
    env->ReleaseStringUTFChars(path, filePath);
    ::free(pixels);
    return items;
}

extern "C"
JNIEXPORT jintArray JNICALL
Java_com_example_nativelib_NativeLib_blurImage(JNIEnv *env, jobject thiz, jstring path) {

    const char *filePath = env->GetStringUTFChars(path, FALSE);
    LOGI("AAA blurImage %s", filePath);

    InitializeMagick(filePath);

    string fname(filePath);

    jintArray items = nullptr;
    try {
        Image image(fname);
        Geometry geometry_size = image.size();
        ::size_t width = geometry_size.width();
        ::size_t height = geometry_size.height();
        LOGI("AAA image size %d x %d", width, height);

        image.blur(5, 2);

        int size = width * height;
        items = env->NewIntArray(size);
        jint *pixels = (jint *) malloc(size * sizeof(jint));
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {

                Magick::ColorRGB pixelColor = image.pixelColor(x, y);

                // Extract the color channel values
                unsigned char alpha = (unsigned char) (pixelColor.alpha() * 255);
                unsigned char red = (unsigned char) (pixelColor.red() * 255);
                unsigned char green = (unsigned char) (pixelColor.green() * 255);
                unsigned char blue = (unsigned char) (pixelColor.blue() * 255);
                int pixel = color_to_int(alpha, red, green, blue);
                int index = y * width + x;
                pixels[index] = pixel;
            }
        }

        env->SetIntArrayRegion(items, 0, size, pixels);
        ::free(pixels);
    } catch (Exception &error_) {
        LOGE("Caught exception: %s", error_.what());
    }

    TerminateMagick();

    env->ReleaseStringUTFChars(path, filePath);

    return items;
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_nativelib_NativeLib_crash(JNIEnv *env, jobject thiz) {
    LOGI("AAA Crashing the process");
    raise(SIGSEGV);
    LOGI("AAA SIGSEGV Sent");
}
