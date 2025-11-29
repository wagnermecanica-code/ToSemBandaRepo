// Configuração de Product Flavors para WeGig
// Gerado automaticamente - NÃO EDITAR MANUALMENTE

import com.android.build.gradle.internal.cxx.configure.gradleLocalProperties

android {
    flavorDimensions.add("environment")
    
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "WeGig DEV")
        }
        
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "WeGig STAGING")
        }
        
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "WeGig")
        }
    }
}
