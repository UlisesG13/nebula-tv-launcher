package com.gathin.tvhome;

import java.util.Calendar;

/**
 * A daily motivational quote (Brian Tracy / personal-development style) shown on Home. Bundled, offline,
 * no network. One per day, chosen by the day of the year so it rotates and a new one appears each morning.
 * Personal build.
 */
final class Quotes {

    private Quotes() {
    }

    private static final String[] LINES = {
        "La clave del éxito es la acción.  — Brian Tracy",
        "Come esa rana: haz primero lo más difícil e importante del día.  — Brian Tracy",
        "Las personas de éxito simplemente tienen hábitos de éxito.  — Brian Tracy",
        "Nunca digas de ti mismo nada que no quieras que sea verdad.  — Brian Tracy",
        "Decide qué quieres, escríbelo y haz algo cada día para lograrlo.  — Brian Tracy",
        "La claridad es poder: mientras más claro seas, más rápido avanzarás.  — Brian Tracy",
        "Invierte en ti mismo: eres tu activo más valioso.  — Brian Tracy",
        "No hay límites para lo que puedes lograr, salvo los de tu mente.  — Brian Tracy",
        "El éxito es predecible: haz lo que hacen los exitosos.  — Brian Tracy",
        "Tu disciplina para posponer la gratificación define tu éxito.  — Brian Tracy",
        "Lee 30 minutos al día sobre tu campo y serás experto en pocos años.  — Brian Tracy",
        "Enfócate en una sola cosa importante a la vez, hasta terminarla.  — Brian Tracy",
        "La confianza se construye con cada promesa que te cumples.  — Brian Tracy",
        "El aprendizaje continuo es el mínimo requisito para el éxito.  — Brian Tracy",
        "Fija metas tan grandes que te emocionen y te asusten a la vez.  — Brian Tracy",
        "Tú eres completamente responsable de tu propia vida.  — Brian Tracy",
        "La autoestima es la reputación que tienes contigo mismo.  — Brian Tracy",
        "Haz lo que temes y el miedo desaparecerá.  — Brian Tracy",
        "Cada minuto en planear ahorra diez en la ejecución.  — Brian Tracy",
        "El optimismo es la cualidad más importante para el éxito.  — Brian Tracy",
        "Los líderes hablan de soluciones; los demás, de problemas.  — Brian Tracy",
        "La persistencia es la autodisciplina en acción.  — Brian Tracy",
        "Mientras más agradeces lo que tienes, más tendrás por agradecer.  — Brian Tracy",
        "Sal de tu zona de confort: ahí es donde ocurre el crecimiento.  — Brian Tracy",
        "El punto de partida de todo gran logro es el deseo ardiente.  — Brian Tracy",
        "Entre más duro trabajes en ti mismo, más suerte tendrás.  — Brian Tracy",
        "Las metas escritas tienen un poder que las ideas sueltas no tienen.  — Brian Tracy",
        "Trata cada problema como una oportunidad para crecer.  — Brian Tracy",
        "El éxito llega cuando la preparación se encuentra con la oportunidad.  — Brian Tracy",
        "Tu vida solo mejora cuando tú mejoras.  — Brian Tracy",
        "No desees que sea más fácil; desea ser mejor.  — Jim Rohn",
        "El éxito son pocas disciplinas simples practicadas cada día.  — Jim Rohn",
        "Trabaja más duro en ti mismo que en tu empleo.  — Jim Rohn",
        "Eres el promedio de las cinco personas con las que más convives.  — Jim Rohn",
        "Cuida tu cuerpo: es el único lugar que tienes para vivir.  — Jim Rohn",
        "La disciplina pesa gramos; el arrepentimiento pesa toneladas.  — Jim Rohn",
        "No tienes que ser grande para empezar, pero debes empezar para ser grande.  — Zig Ziglar",
        "Tu actitud, no tu aptitud, determina tu altitud.  — Zig Ziglar",
        "La gente dice que la motivación no dura; bañarse tampoco, por eso se hace a diario.  — Zig Ziglar",
        "El único modo de hacer un gran trabajo es amar lo que haces.  — Steve Jobs",
        "La mejor forma de predecir el futuro es crearlo.  — Peter Drucker",
        "Lo que se mide, se mejora.  — Peter Drucker",
        "Un objetivo sin un plan es solo un deseo.  — Antoine de Saint-Exupéry",
        "El que tiene un porqué para vivir soporta casi cualquier cómo.  — Nietzsche",
        "Caer está permitido; levantarse es obligatorio.  — Proverbio",
        "Pequeñas mejoras diarias llevan a resultados extraordinarios.  — Aprendizaje personal",
        "Hecho es mejor que perfecto: empieza hoy, mejora mañana.  — Aprendizaje personal",
        "La constancia vence al talento cuando el talento no es constante.  — Aprendizaje personal",
        "Tu futuro se decide por lo que haces hoy, no mañana.  — Aprendizaje personal",
        "Rodéate de quienes te empujen a crecer.  — Aprendizaje personal",
        "Gana el día: una tarea importante terminada antes del mediodía.  — Aprendizaje personal",
    };

    /** The quote for today, chosen by the day of the year so it changes each morning. */
    static String ofDay() {
        int day = Calendar.getInstance().get(Calendar.DAY_OF_YEAR);
        return LINES[day % LINES.length];
    }
}
