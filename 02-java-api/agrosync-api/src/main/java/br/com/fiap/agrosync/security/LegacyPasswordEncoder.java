package br.com.fiap.agrosync.security;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/**
 * Senhas novas são gravadas com BCrypt. As linhas de teste do script do banco têm senha em texto puro
 * (ex.: senha123); elas continuam funcionando no login e são convertidas para BCrypt no primeiro acesso.
 */
public class LegacyPasswordEncoder implements PasswordEncoder {

    private final BCryptPasswordEncoder bcrypt = new BCryptPasswordEncoder();

    @Override
    public String encode(CharSequence senha) {
        return bcrypt.encode(senha);
    }

    @Override
    public boolean matches(CharSequence senha, String armazenada) {
        if (armazenada == null) {
            return false;
        }
        if (armazenada.startsWith("$2")) {
            return bcrypt.matches(senha, armazenada);
        }
        return MessageDigest.isEqual(
                senha.toString().getBytes(StandardCharsets.UTF_8),
                armazenada.getBytes(StandardCharsets.UTF_8));
    }
}
