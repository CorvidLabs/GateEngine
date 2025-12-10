/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if HTML5
import JavaScriptKit
import WebAPIBase
import DOM
import WebGL1
import WebGL2

class WebGL2Texture: TextureBackend {
    let renderTarget: WebGL2RenderTarget?
    let _textureId: WebGL1.WebGLTexture?
    var _size: Size2i?
    let managed: Bool

    var textureId: WebGL1.WebGLTexture {
        if let renderTarget {
            return renderTarget.colorTexture!
        }
        return _textureId!
    }

    var size: Size2i {
        if let renderTarget {
            return renderTarget.size
        }
        return _size!
    }

    required init(renderTargetBackend: any RenderTargetBackend) {
        self.renderTarget = (renderTargetBackend as! WebGL2RenderTarget)
        self._size = nil
        self._textureId = nil
        self.managed = false
    }

    required init(rawTexture: RawTexture, mipMapping: MipMapping) {
        self.renderTarget = nil
        self.managed = true
        self._size = rawTexture.imageSize
        let gl = WebGL2Renderer.context
        // Generate and bind texture.
        self._textureId = gl.createTexture()
        self.replaceData(with: rawTexture, mipMapping: mipMapping)
    }

    func replaceData(with rawTexture: RawTexture, mipMapping: MipMapping) {
        self._size = rawTexture.imageSize
        let gl = WebGL2Renderer.context

        gl.bindTexture(target: GL.TEXTURE_2D, texture: textureId)

        // Set parameters.
        gl.texParameteri(target: GL.TEXTURE_2D, pname: GL.TEXTURE_WRAP_S, param: GLint(GL.REPEAT))
        gl.texParameteri(target: GL.TEXTURE_2D, pname: GL.TEXTURE_WRAP_T, param: GLint(GL.REPEAT))

        gl.texParameteri(
            target: GL.TEXTURE_2D,
            pname: GL.TEXTURE_MIN_FILTER,
            param: GLint(GL.NEAREST)
        )
        gl.texParameteri(
            target: GL.TEXTURE_2D,
            pname: GL.TEXTURE_MAG_FILTER,
            param: GLint(GL.NEAREST)
        )

        // Set the texture data.
        gl.pixelStorei(pname: GL.UNPACK_ALIGNMENT, param: 1)

        gl.bindTexture(target: GL.TEXTURE_2D, texture: self.textureId)

        let data = JSTypedArray<UInt8>(rawTexture.imageData)
        gl.texImage2D(
            target: GL.TEXTURE_2D,
            level: 0,
            internalformat: GLint(GL.RGBA),
            width: GLsizei(rawTexture.imageSize.width),
            height: GLsizei(rawTexture.imageSize.height),
            border: 0,
            format: GL.RGBA,
            type: GL.UNSIGNED_BYTE,
            pixels: .uint8Array(data)
        )

        if case let .auto(levels) = mipMapping, levels > 1 {
            gl.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_MAX_LEVEL,
                param: GLint(levels)
            )
            gl.generateMipmap(target: GL.TEXTURE_2D)
        }
    }

    deinit {
        if managed, let _textureId {
            WebGL2Renderer.context.deleteTexture(texture: _textureId)
        }
    }
}

#endif
