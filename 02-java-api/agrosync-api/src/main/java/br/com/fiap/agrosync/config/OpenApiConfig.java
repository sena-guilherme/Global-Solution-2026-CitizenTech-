package br.com.fiap.agrosync.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(info = @Info(
        title = "AgroSync API",
        version = "1.0.0",
        description = "API REST do AgroSync (CitizenTech): áreas de cultivo, irrigação, alertas e comunidade de produtores. "
                + "Faça login em /api/auth/login, copie o token e clique em Authorize."))
@SecurityScheme(name = "bearerAuth", type = SecuritySchemeType.HTTP, scheme = "bearer", bearerFormat = "JWT")
public class OpenApiConfig {
}
