package br.com.fiap.agrosync.security;

import br.com.fiap.agrosync.domain.Papel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

/** Define o papel pelo e-mail: os e-mails de app.security.admin-emails são ADMIN; os demais, PRODUTOR. */
@Component
public class PapelResolver {

    private final Set<String> admins;

    public PapelResolver(@Value("${app.security.admin-emails:admin@agrosync.com}") String emails) {
        this.admins = Arrays.stream(emails.split(","))
                .map(s -> s.trim().toLowerCase())
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toSet());
    }

    public Papel papelDe(String email) {
        return email != null && admins.contains(email.trim().toLowerCase()) ? Papel.ADMIN : Papel.PRODUTOR;
    }
}
