import CGLFW3
import SGLOpenGL

let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

func keyCallback(_ window: OpaquePointer!, _ key: Int32, _ scancode: Int32, _ action: Int32, _ mode: Int32) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE)
    }
}

let vertices:[GLfloat] = [
  -0.5, -0.5, 0.0,
   0.5, -0.5, 0.0,
   0.0,  0.5, 0.0
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
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)

    var VAO: GLuint = 0
    glGenVertexArrays(n: 1, arrays: &VAO)
    defer { glDeleteVertexArrays(1, &VAO) }

    var VBO: GLuint = 0
    glGenBuffers(n: 1, buffers: &VBO)
    defer { glDeleteBuffers(1, &VBO)  }

    glBindVertexArray(VAO)

    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO)
    glBufferData(target: GL_ARRAY_BUFFER, size: MemoryLayout<GLfloat>.stride * vertices.count, data: vertices, usage: GL_STATIC_DRAW)

    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT, normalized: false, stride: GLsizei(MemoryLayout<GLfloat>.stride * 3), pointer: nil)
    glEnableVertexAttribArray(0)

    glBindVertexArray(0)

    while glfwWindowShouldClose(window) == GL_FALSE {
        glfwPollEvents()

        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)

        glUseProgram(shaderProgram)
        glBindVertexArray(VAO)
        glDrawArrays(GL_TRIANGLES, 0, 3)
        glBindVertexArray(0)

        glfwSwapBuffers(window)
    }
}

main()

