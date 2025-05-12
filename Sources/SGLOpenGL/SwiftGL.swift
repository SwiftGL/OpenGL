// Copyright (c) 2015-2016 David Turnbull
// Copyright (c) 2013-2016 The Khronos Group Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and/or associated documentation files (the
// "Materials"), to deal in the Materials without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Materials, and to
// permit persons to whom the Materials are furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Materials.
//
// THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.


public typealias GLenum = Int32
public typealias GLboolean = Bool
public typealias GLbitfield = UInt32
public typealias GLbyte = Int8
public typealias GLshort = Int16
public typealias GLint = Int32
public typealias GLclampx = Int32
public typealias GLubyte = UInt8
public typealias GLushort = UInt16
public typealias GLuint = UInt32
public typealias GLsizei = Int32
public typealias GLfloat = Float
public typealias GLclampf = Float
public typealias GLdouble = Double
public typealias GLclampd = Double
public typealias GLeglImageOES = UnsafeMutableRawPointer
public typealias GLchar = Int8
public typealias GLcharARB = Int8
public typealias GLhandleARB = UnsafeMutableRawPointer
public typealias GLhalfARB = UInt16
public typealias GLhalf = UInt16
public typealias GLfixed = Int32
public typealias GLintptr = Int
public typealias GLsizeiptr = Int
public typealias GLint64 = Int64
public typealias GLuint64 = UInt64
public typealias GLintptrARB = Int
public typealias GLsizeiptrARB = Int
public typealias GLint64EXT = Int64
public typealias GLuint64EXT = UInt64
public typealias GLsync = OpaquePointer
public typealias GLhalfNV = UInt16
public typealias GLvdpauSurfaceNV = Int

public typealias GLDEBUGPROC = @convention(c)
    (GLenum, GLenum, GLuint, GLenum, GLsizei, UnsafePointer<GLchar>, UnsafeRawPointer) -> Void
public typealias GLDEBUGPROCARB = @convention(c)
    (GLenum, GLenum, GLuint, GLenum, GLsizei, UnsafePointer<GLchar>, UnsafeRawPointer) -> Void
public typealias GLDEBUGPROCKHR = @convention(c)
    (GLenum, GLenum, GLuint, GLenum, GLsizei, UnsafePointer<GLchar>, UnsafeRawPointer) -> Void
public typealias GLDEBUGPROCAMD = @convention(c)
    (GLuint, GLenum, GLenum, GLsizei, UnsafePointer<GLchar>, UnsafeMutableRawPointer) -> Void

class CommandInfo : CustomStringConvertible {
    let name: String
    let support: [String]
    init(_ name: String, _ support: [String]) {
        self.name = name
        self.support = support
    }
    var description: String {
        return "(\(name): \(support))"
    }
}

private func buildError(info: CommandInfo) -> Never {
    var adds = ""
    var rems = ""
    var exts = ""
    for support in info.support {
        let short = support[support.index(support.startIndex, offsetBy: 1)..<support.endIndex]
        if support[support.startIndex] == "+" {
            if adds.count > 0 {
                adds += ", "
            }
            adds += short
        } else if support[support.startIndex] == "-" {
            if rems.count > 0 {
                rems += ", "
            }
            rems += short
        } else {
            if exts.count > 0 {
                exts += ", "
            }
            exts += "GL_\(support)"
        }
    }
    var s = "\(info.name) not found"
    if info.support.count > 0 {
        s += "\n"
    }
    if adds.count > 0 {
        s += "Added in OpenGL \(adds)\n"
    }
    if rems.count > 0 {
        s += "Removed in OpenGL \(rems)\n"
    }
    if exts.count > 0 {
        s += "Extensions: \(exts)\n"
    }
    fatalError(s)
}

func getAddress(_ info: CommandInfo) -> UnsafeMutableRawPointer {
    guard let fp = lookupAddress(info: info) else {
        buildError(info: info)
    }
    return fp
}

// Platform specific sections below.
// To support a new platform, implement lookupAddress.

#if os(OSX)

    import Darwin

    let openGLframework = "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    var dlopenHandle: UnsafeMutableRawPointer? = nil
    
    func lookupAddress(info: CommandInfo) -> UnsafeMutableRawPointer? {
        if dlopenHandle == nil {
            dlopenHandle = dlopen(openGLframework, RTLD_LAZY)
        }
        guard let handle = dlopenHandle else {
            fatalError("Failed to dlopen OpenGL.framework")
        }
        return dlsym(handle, info.name)
    }

#elseif os(Linux)

    import Glibc

    var dlopenHandle: UnsafeMutableRawPointer?
    var glXGetProcAddress:(@convention(c) (UnsafePointer<GLchar>) -> UnsafeMutableRawPointer)? = nil
    
    func lookupAddress(info: CommandInfo) -> UnsafeMutableRawPointer? {
        if dlopenHandle == nil {
            dlopenHandle = dlopen(nil, RTLD_LAZY | RTLD_LOCAL)
        }
        if dlopenHandle == nil {
            fatalError("Failed to obtain dlopenHandle")
        }
        if glXGetProcAddress == nil {
            let fp = dlsym(dlopenHandle, "glXGetProcAddressARB")
            if fp != nil {
                glXGetProcAddress = unsafeBitCast(fp, to: type(of: glXGetProcAddress))
            }
        }
        if glXGetProcAddress == nil {
            let fp = dlsym(dlopenHandle, "glXGetProcAddress")
            if fp != nil {
                glXGetProcAddress = unsafeBitCast(fp, to: type(of: glXGetProcAddress))
            }
        }
        if glXGetProcAddress == nil {
            fatalError("Failed to find glXGetProcAddress")
        }
        return glXGetProcAddress!(info.name)
    }

#elseif os(Windows) 

    import WinSDK
    typealias wglGetProcAddressType = @convention(c) (LPCSTR) -> UnsafeMutableRawPointer?
    typealias wglGetCurrentContextType = @convention(c) () -> HGLRC

    var opengl32Handle: HMODULE? = {
        LoadLibraryA("opengl32.dll")
    }()

    func loadSymbol(named: String) -> FARPROC? {
        guard let opengl32Handle else {
            fatalError("[ERROR]: COULD NOT LOAD opengl32.dll")
        }
        
        guard let symbol = GetProcAddress(opengl32Handle, named) else {
            fatalError("[ERROR]: GetProcAddress(opengl32Handle, \"\(named)\") returned nil")
        }

        return symbol
    }

    func loadSymbol<T>(named: String, as _: T.Type = T.self) -> T? {
        guard let symbol = loadSymbol(named: named) else {
            return nil
        }

        return unsafeBitCast(symbol, to: T.self)
    }

    var wglGetCurrentContext: Optional<wglGetCurrentContextType> = {
        let result = loadSymbol(named: "wglGetCurrentContext", as: wglGetCurrentContextType.self)
        return result
    }()

    var wglGetProcAddress: Optional<wglGetProcAddressType> = { // parse issue with 'wglGetProcAddressType?'
        let result = loadSymbol(named: "wglGetProcAddress", as: wglGetProcAddressType.self)
        return result
    }()

    func lookupAddress(info: CommandInfo) -> UnsafeMutableRawPointer? {
        guard let wglGetProcAddress else {
            fatalError("[ERROR]: wglGetProcAddress not initialized!")
        }

        if let result = wglGetProcAddress(info.name) {
            return result
        } else {
            guard let symbol = loadSymbol(named: info.name), 
                  let result = UnsafeMutableRawPointer(bitPattern: unsafeBitCast(symbol, to: UInt.self)) else {
                    let error = "[ERROR]: Could not find address for \(info.name)\n" + {
                        if let currentContext = wglGetCurrentContext?() {
                            "Current context handle: \(currentContext)"
                        } else {
                            "Current context handle unavailable"
                        }
                    }();

                    fatalError(error)
            }

            return result
        }
    }

#else

    func lookupAddress(info: commandInfo) -> UnsafeMutableRawPointer? {
        fatalError("Unsupported OS")
    }

#endif
