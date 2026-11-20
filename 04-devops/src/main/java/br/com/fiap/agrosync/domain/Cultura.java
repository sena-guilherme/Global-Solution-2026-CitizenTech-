package br.com.fiap.agrosync.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "CULTURA")
@Getter
@Setter
@NoArgsConstructor
public class Cultura {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_cultura")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_area", nullable = false)
    private Area area;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false, length = 20)
    private TipoCultura tipo;

    @Column(name = "nome", nullable = false, length = 80)
    private String nome;

    @Column(name = "data_plantio", nullable = false)
    private LocalDate dataPlantio;

    @Enumerated(EnumType.STRING)
    @Column(name = "estagio", nullable = false, length = 30)
    private Estagio estagio;

    @OneToMany(mappedBy = "cultura", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Alerta> alertas = new ArrayList<>();
}
