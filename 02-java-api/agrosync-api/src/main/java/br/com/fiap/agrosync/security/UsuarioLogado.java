package br.com.fiap.agrosync.security;

import br.com.fiap.agrosync.domain.Papel;
import br.com.fiap.agrosync.domain.Produtor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

/**
 * Usuário autenticado. A tabela PRODUTOR não tem coluna de papel, então o papel
 * (PRODUTOR ou ADMIN) é definido pela configuração app.security.admin-emails.
 */
public class UsuarioLogado implements UserDetails {

    @Getter
    private final Long id;
    @Getter
    private final String nome;
    @Getter
    private final String email;
    @Getter
    private final String municipio;
    @Getter
    private final String regiao;
    @Getter
    private final Papel papel;
    private final String senha;

    public UsuarioLogado(Long id, String nome, String email, String municipio, String regiao, Papel papel, String senha) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.municipio = municipio;
        this.regiao = regiao;
        this.papel = papel;
        this.senha = senha;
    }

    public static UsuarioLogado de(Produtor p, Papel papel) {
        return new UsuarioLogado(p.getId(), p.getNome(), p.getEmail(), p.getMunicipio(), p.getRegiao(), papel, p.getSenha());
    }

    public boolean isAdmin() {
        return papel == Papel.ADMIN;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + papel.name()));
    }

    @Override
    public String getPassword() {
        return senha;
    }

    @Override
    public String getUsername() {
        return email;
    }
}
