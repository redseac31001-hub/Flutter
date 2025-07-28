// buildscript {
//     val kotlinVersion = "1.9.22"
//     // by exttra('1.9.20')
//     repositories {
//         google()
//         mavenCentral()
//         maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
//         // maven{url = uri("https://maven.aliyun.com/repository/google") }
//         // maven{url = uri("https://maven.aliyun.com/repository/google-plugin")}
//         // maven{url = uri("https://maven.aliyun.com/repository/public")}
//         // maven{url = uri("https://maven.aliyun.com/repository/jcenter")}
//     }

//     dependencies {
//         classpath("com.android.tools.build:gradle:8.3.0") 
//         classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")    
//     }
// }
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
// // 确保所有子项目使用默认构建配置
// subprojects {
//     // 移除任何可能影响构建路径的配置
//     afterEvaluate {
//         // 如果有自定义的输出目录配置，重置为默认
//         if (project.hasProperty("android")) {
//             println("Project ${project.name} build directory: ${project.layout.buildDirectory.get()}")
//         }
//     }
// }
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
