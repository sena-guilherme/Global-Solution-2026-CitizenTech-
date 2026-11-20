package br.com.fiap.agrosync.domain;


public enum ClassificacaoUmidade {
    CRITICO("Irrigação urgente. Risco alto de perda da safra.", Severidade.CRITICO),
    MODERADO("Irrigar nas próximas 24 horas.", Severidade.MODERADO),
    NORMAL("Umidade adequada. Manter monitoramento.", Severidade.NORMAL),
    EXCESSO("Solo encharcado. Suspender irrigação.", Severidade.NORMAL);

    private final String recomendacao;
    private final Severidade severidadeDoAlerta;

    ClassificacaoUmidade(String recomendacao, Severidade severidadeDoAlerta) {
        this.recomendacao = recomendacao;
        this.severidadeDoAlerta = severidadeDoAlerta;
    }

    public String getRecomendacao() {
        return recomendacao;
    }

    public Severidade getSeveridadeDoAlerta() {
        return severidadeDoAlerta;
    }

    public static ClassificacaoUmidade de(double umidade) {
        if (umidade < 20) {
            return CRITICO;
        } else if (umidade < 35) {
            return MODERADO;
        } else if (umidade <= 70) {
            return NORMAL;
        }
        return EXCESSO;
    }
}
