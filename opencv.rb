require 'formula'

class Opencv < Formula
  #homepage 'http://opencv.org/'
  #url 'https://github.com/Itseez/opencv/archive/2.4.7.1.tar.gz'
  #sha1 'b6b0dd72356822a482ca3a27a7a88145aca6f34c'
  #url 'https://github.com/Itseez/opencv/archive/2.4.8.tar.gz'
  #sha1 '61b95974bf9689b94b169c39aed6c85a2e124837'
  #url 'https://github.com/Itseez/opencv/archive/2.4.8.2.tar.gz'
  #sha1 '15c91f8fc806d39735ac4ce6a1c381541d4b5c80'
  homepage 'https://github.com/Itseez/opencv'
  head 'https://github.com/Itseez/opencv.git', :using => :git

  option "32-bit"
  option "with-java", "Build with Java support"
  option "with-qt", "Build the Qt4 backend to HighGUI"
  option "with-tbb", "Enable parallel code in OpenCV using Intel TBB"
  option "with-tests", "Build with accuracy & performance tests"
  option "without-opencl", "Disable GPU code in OpenCV using OpenCL"

  option :cxx11

  depends_on :ant if build.with? "java"
  depends_on "cmake"      => :build
  depends_on "eigen"      => :recommended
  depends_on "jasper"
  depends_on "jpeg"
  depends_on :libpng
  depends_on "libtiff"
  depends_on "numpy"      => :python
  depends_on "openexr"    => :recommended
  depends_on "openni"     => :optional
  depends_on "pkg-config" => :build
  depends_on :python
  depends_on "qt"         => :optional
  depends_on "tbb"        => :optional

  # Can also depend on ffmpeg, but this pulls in a lot of extra stuff that
  # you don't need unless you're doing video analysis, and some of it isn't
  # in Homebrew anyway. Will depend on openexr if it's installed.
  depends_on 'ffmpeg' => :optional

  def install
    jpeg = Formula["jpeg"]
    py_prefix = %x(python-config --prefix).chomp

    # NOTE:  `python-config` is no longer found in /usr/local/bin after
    #        the introduction of `superenv` -- but oddly only for the HEAD
    #        install.  The workaround is to install with `--env=std` (or
    #        one could hardwire the python-config path).
    #aa = `printenv PATH`
    #print aa
    #bb = `which python`
    #print bb
    #cc = `which python-config`
    #print cc

    # NOTE: requires `--env=std` to find correct `python-config`:
    #py_prefix = `python-config --prefix`.strip
    #py_prefix = `python-config --prefix`.split
    #py_prefix = '%x(python-config --prefix).chomp'
    #py_prefix = `#{HOMEBREW_PREFIX}/bin/python-config --prefix`.strip
    #py_prefix = '/usr/local/Cellar/python/2.7.6/Frameworks/Python.framework/Versions/2.7'
    #print py_prefix

    ENV.cxx11 if build.cxx11?
    args = std_cmake_args + %W(
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DWITH_CUDA=OFF
      -DBUILD_ZLIB=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_PNG=OFF
      -DBUILD_OPENEXR=OFF
      -DBUILD_JASPER=OFF
      -DBUILD_JPEG=OFF
      -DJPEG_INCLUDE_DIR=#{jpeg.opt_include}
      -DJPEG_LIBRARY=#{jpeg.opt_lib}/libjpeg.dylib
      -DPYTHON_LIBRARY=#{py_prefix}/Python
      -DPYTHON_INCLUDE_DIR=#{py_prefix}/Headers
    )

    if build.without? "tests"
      args << "-DBUILD_TESTS=OFF" << "-DBUILD_PERF_TESTS=OFF"
    end

    args << "-DBUILD_opencv_java=" + ((build.with? "java") ? "ON" : "OFF")
    args << "-DWITH_OPENEXR=" + ((build.with? "openexr") ? "ON" : "OFF")
    args << "-DWITH_QT=" + ((build.with? "qt") ? "ON" : "OFF")
    args << "-DWITH_TBB=" + ((build.with? "tbb") ? "ON" : "OFF")
    args << "-DWITH_FFMPEG=" + ((build.with? "ffmpeg") ? "ON" : "OFF")

    # OpenCL 1.1 is required, but Snow Leopard and older come with 1.0
    args << "-DWITH_OPENCL=OFF" if build.without? "opencl" or MacOS.version < :lion

    if build.with? "openni"
      args << "-DWITH_OPENNI=ON"
      # Set proper path for Homebrew's openni
      inreplace "cmake/OpenCVFindOpenNI.cmake" do |s|
        s.gsub! "/usr/include/ni", "#{Formula["openni"].opt_include}/ni"
        s.gsub! "/usr/lib", "#{Formula["openni"].opt_lib}"
      end
    end

    if build.include? "32-bit"
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
      args << "-DOPENCV_EXTRA_C_FLAGS='-arch i386 -m32'"
      args << "-DOPENCV_EXTRA_CXX_FLAGS='-arch i386 -m32'"
    end

    if ENV.compiler == :clang and !build.bottle?
      args << '-DENABLE_SSSE3=ON' if Hardware::CPU.ssse3?
      args << '-DENABLE_SSE41=ON' if Hardware::CPU.sse4?
      args << '-DENABLE_SSE42=ON' if Hardware::CPU.sse4_2?
      args << '-DENABLE_AVX=ON' if Hardware::CPU.avx?
    end

    mkdir "macbuild" do
      system "cmake", "..", *args
      system "make"
      system "make install"
    end
  end
end




