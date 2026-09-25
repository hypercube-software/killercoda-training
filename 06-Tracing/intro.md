<br>

Dans ce scenario, on va apprendre à tracer plusieurs appels distribués avec [Micrometer Tracing](https://docs.micrometer.io/tracing/reference/) qui est un standard dans le monde Java pour tracer.

SpringBoot l'utilise et offre deux implémentations:
- Une pour OpenTelemetry
- Une pour OpenZipkin Brave

Pour un TP, Zipkin est parfait. En prod on pourra trouver des solutions plus lourdes avec un collecteur OpenTelemetry et Grafana Tempo.
