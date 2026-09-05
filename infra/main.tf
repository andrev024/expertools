# Este recurso describe la base de datos que YA CREASTE manualmente en Aiven.
# En vez de dejar que Terraform la cree de nuevo (lo que la borraria y
# recrearia, perdiendo tus datos), la vamos a "importar" -- es decir, decirle
# a Terraform "esta cosa ya existe, adminstrala a partir de ahora sin tocarla".

resource "aiven_mysql" "expertools_db" {
  project      = var.aiven_project
  service_name = "expertools-db"
  cloud_name   = "do-sfo"
  plan         = "free-1-1gb"

  # Evita que un "terraform apply" accidental destruya la base de datos real
  # con la que tu amigo ya esta trabajando.
  termination_protection = true
}
