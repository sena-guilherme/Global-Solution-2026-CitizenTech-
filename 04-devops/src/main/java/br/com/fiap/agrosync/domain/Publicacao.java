package br.com.fiap.agrosync.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "PUBLICACAO")
@Getter
@Setter
@NoArgsConstructor
public class Publicacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_publicacao")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_produtor", nullable = false)
    private Produtor produtor;

    @Column(name = "texto", nullable = false, length = 500)
    private String texto;

    @Column(name = "cultura", nullable = false, length = 80)
    private String cultura;

    @Column(name = "regiao", nullable = false, length = 60)
    private String regiao;

    @Column(name = "data_publicacao", nullable = false)
    private LocalDateTime dataPublicacao = LocalDateTime.now();

    @Column(name = "confirmacoes", nullable = false)
    private int confirmacoes;
}
