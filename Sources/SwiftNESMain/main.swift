import CGLFW3
import SGLOpenGL

let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

func keyCallback(_ window: OpaquePointer!, _ key: Int32, _ scancode: Int32, _ action: Int32, _ mode: Int32) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE)
    }
}

let vertices: [GLfloat] = [
     0.5,  0.5, 0.0,  // Top Right
     0.5, -0.5, 0.0,  // Bottom Right
    -0.5, -0.5, 0.0,  // Bottom Left
    -0.5,  0.5, 0.0   // Top Left 
]


let vTriangle1:[GLfloat] = [
   0.0, 0.0, 0.0,
   1.0, 0.0, 0.0,
   0.5, 1.0, 0.0
]

let vTriangle2:[GLfloat] = [
  -1.0, 0.0, 0.0,
   0.0, 0.0, 0.0,
  -0.5, 1.0, 0.0
]

let indices: [GLuint] = [
    0, 1, 3,  // First Triangle
    1, 2, 3   // Second Triangle
]

let vertextShaderSource = """
#version 330 core

layout (location = 0) in vec3 position;

void main() {
    gl_Position = vec4(position.x, position.y, position.z, 1.0);
}
"""

let fragmentShaderSource = """
#version 330 core

out vec4 color;

void main() {
    color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
"""

let fragmentShaderSource2 = """
#version 330 core

out vec4 color;

void main() {
    color = vec4(1.0f, 1.0f, 0.1f, 1.0f);
}
"""

func main() {
    glfwInit()
    defer { glfwTerminate() }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE)
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)

    let window = glfwCreateWindow(WIDTH, HEIGHT, "LearnSwiftGL", nil, nil)
    glfwMakeContextCurrent(window)
    guard window != nil else {
        print("Failed to create GLFW window")
        return
    }

    glViewport(x: 0, y: 0, width: WIDTH, height: HEIGHT)

    glfwSetKeyCallback(window, keyCallback)

    let vertexShader: GLuint = glCreateShader(type: GL_VERTEX_SHADER)
    do {
        vertextShaderSource.withCString {
            var s = [$0]
            glShaderSource(shader: vertexShader, count: 1, string: &s, length: nil)
        }
        glCompileShader(vertexShader)
        var success: GLint = 0
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success)
        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(vertexShader, 512, nil, &infoLog)
            fatalError(String(cString: infoLog))
        }
    }

    let vertexShader2: GLuint = glCreateShader(type: GL_VERTEX_SHADER)
    do {
        vertextShaderSource.withCString {
            var s = [$0]
            glShaderSource(shader: vertexShader2, count: 1, string: &s, length: nil)
        }
        glCompileShader(vertexShader2)
        var success: GLint = 0
        glGetShaderiv(vertexShader2, GL_COMPILE_STATUS, &success)
        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(vertexShader2, 512, nil, &infoLog)
            fatalError(String(cString: infoLog))
        }
    }

    let fragmentShader: GLuint = glCreateShader(type: GL_FRAGMENT_SHADER)
    do {
        fragmentShaderSource.withCString {
            var s = [$0]
            glShaderSource(shader: fragmentShader, count: 1, string: &s, length: nil)
        }
        glCompileShader(fragmentShader)
        var success: GLint = 0
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success)
        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(fragmentShader, 512, nil, &infoLog)
            fatalError(String(cString: infoLog))
        }
    }

    let fragmentShader2: GLuint = glCreateShader(type: GL_FRAGMENT_SHADER)
    do {
        fragmentShaderSource2.withCString {
            var s = [$0]
            glShaderSource(shader: fragmentShader2, count: 1, string: &s, length: nil)
        }
        glCompileShader(fragmentShader2)
        var success: GLint = 0
        glGetShaderiv(fragmentShader2, GL_COMPILE_STATUS, &success)
        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(fragmentShader2, 512, nil, &infoLog)
            fatalError(String(cString: infoLog))
        }
    }

    let shaderProgram: GLuint = glCreateProgram()
    defer { glDeleteProgram(shaderProgram) }
    do {
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragmentShader)
        glLinkProgram(shaderProgram)

        var success: GLint = 0
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success)
        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(shaderProgram, 512, nil, &infoLog)
            fatalError(String(cString: infoLog))
        }
    }

    let shaderProgram2: GLuint = glCreateProgram()
    defer { glDeleteProgram(shaderProgram2) }
    do {
        glAttachShader(shaderProgram2, vertexShader2)
        glAttachShader(shaderProgram2, fragmentShader2)
        glLinkProgram(shaderProgram2)

        var success: GLint = 0
        glGetProgramiv(shaderProgram2, GL_LINK_STATUS, &success)
        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(shaderProgram2, 512, nil, &infoLog)
            print("\(String(cString: infoLog))")
            fatalError(String(cString: infoLog))
        }
    }
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)
    glDeleteShader(fragmentShader2)

    var VAO1: GLuint = 0
    glGenVertexArrays(n: 1, arrays: &VAO1)
    defer { glDeleteVertexArrays(1, &VAO1) }

    var VAO2: GLuint = 0
    glGenVertexArrays(n: 1, arrays: &VAO2)
    defer { glDeleteVertexArrays(1, &VAO2) }

    var VBO1: GLuint = 0
    glGenBuffers(n: 1, buffers: &VBO1)
    defer { glDeleteBuffers(1, &VBO1)  }

    // var EBO: GLuint = 0
    // glGenBuffers(n: 1, buffers: &EBO)
    // defer { glDeleteBuffers(1, &EBO) }

    glBindVertexArray(VAO1)
    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO1)
    glBufferData(target: GL_ARRAY_BUFFER, size: MemoryLayout<GLfloat>.stride * vTriangle1.count, data: vTriangle1, usage: GL_STATIC_DRAW)

    // glBindBuffer(target: GL_ELEMENT_ARRAY_BUFFER, buffer: EBO)
    // glBufferData(target: GL_ELEMENT_ARRAY_BUFFER, size: MemoryLayout<GLuint>.stride * indices.count, data: indices, usage: GL_STATIC_DRAW)

    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT, normalized: false, stride: GLsizei(MemoryLayout<GLfloat>.stride * 3), pointer: nil)
    glEnableVertexAttribArray(0)

    var VBO2: GLuint = 0
    glGenBuffers(n: 1, buffers: &VBO2)
    defer { glDeleteBuffers(1, &VBO2)  }

    glBindVertexArray(VAO2)
    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO2)
    glBufferData(target: GL_ARRAY_BUFFER, size: MemoryLayout<GLfloat>.stride * vTriangle2.count, data: vTriangle2, usage: GL_STATIC_DRAW)

    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT, normalized: false, stride: GLsizei(MemoryLayout<GLfloat>.stride * 3), pointer: nil)
    glEnableVertexAttribArray(0)

    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

    while glfwWindowShouldClose(window) == GL_FALSE {
        glfwPollEvents()

        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)

        glUseProgram(shaderProgram)

        glBindVertexArray(VAO1)
        glDrawArrays(GL_TRIANGLES, 0, 3)

        glUseProgram(shaderProgram2)

        glBindVertexArray(VAO2)
        glDrawArrays(GL_TRIANGLES, 0, 3)

        //glBindBuffer(target: GL_ELEMENT_ARRAY_BUFFER, buffer: EBO)
        // glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)
        glBindVertexArray(0)

        glfwSwapBuffers(window)
    }
}

main()

