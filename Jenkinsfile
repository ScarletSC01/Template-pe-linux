pipeline {
    agent any

    environment {
        // ===== Config base/oculta =====
        PAIS = 'PE'
        SISTEMA_OPERATIVO_BASE = 'Linux'
        SNAPSHOT_ENABLED = 'true'
        SNAPSHOT_VM = 'snap_vm_01'
        SNAPSHOT_SO = 'snap_os_01'
        SNAPSHOT_DISK = 'snap_disk_01'
        LABEL = 'vm-template'
        ENABLE_STARTUP_SCRIPT = 'true'
        // ===== Config Jira/teams =====
        JIRA_API_URL = "https://bancoripley1.atlassian.net/rest/api/3/issue/"
        TICKET_JIRA = "AJI-83"
        TEAMS_WEBHOOK = "https://accenture.webhook.office.com/webhookb2/8fb63984-6f5f-4c2a-a6d3-b4fce2feb8ee@e0793d39-0939-496d-b129-198edd916feb/IncomingWebhook/334818fae3a84ae484512967d1d3f4f1/b08cc148-e951-496b-9f46-3f7e35f79570/V27mobtZgWmAzxIvjHCY5CMAFKPZptkEnQbT5z7X84QNQ1"
        PROYECT_JIRA     = 'AJI'
        TITULO_JIRA      = 'Creación de Instancia base de Maquina virtual Linux'
        ID_ISSUETYPE_JIRA = '14898'
        // intentos máximos para crear instancia
        MAX_RETRIES = 2
        // Valor efectivo de backup (se define en Validación de variables)
        BACKUP_EFFECTIVE = ''
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    //PARÁMETROS DEL PIPELINE
parameters {

    // ================== GCP / ENTORNO ==================
    string(name: 'PROJECT_ID', defaultValue: '', description: 'ID del proyecto en GCP')
    string(name: 'REGION', defaultValue: 'us-central1', description: 'Región de despliegue')
    string(name: 'ZONE', defaultValue: 'us-central1-a', description: 'Zona de despliegue')
    choice(name: 'ENVIRONMENT', choices: ['desarrollo', 'pre-productivo', 'produccion'], description: 'Ambiente de ejecución')

    // ================== CONFIGURACIÓN DE VM ==================
    string(name: 'VM_NAME', defaultValue: 'vm-pe-linux', description: 'Nombre de la máquina virtual')
    choice(name: 'PROCESSOR_TECH', choices: ['n2', 'e2'], description: 'Tipo de procesador utilizado')
    choice(name: 'VM_TYPE', choices: ['n2-standard', 'e2-standard'], description: 'Familia/tipo de VM')
    string(name: 'VM_CORES', defaultValue: '2', description: 'Cantidad de vCPUs asignadas')
    string(name: 'VM_MEMORY', defaultValue: '8', description: 'Memoria RAM (en GB)')
    choice(name: 'OS_TYPE', choices: ['linux-ubuntu-22', 'linux-ubuntu-20', 'linux-debian-12'], description: 'Sistema operativo base')

    // ================== ALMACENAMIENTO ==================
    string(name: 'DISK_SIZE', defaultValue: '100', description: 'Tamaño del disco en GB')
    choice(name: 'DISK_TYPE', choices: ['pd-ssd', 'pd-balanced', 'pd-standard'], description: 'Tipo de disco')
    choice(name: 'AUTO_DELETE_DISK', choices: ['true', 'false'], description: 'Eliminar disco automáticamente al borrar VM')

    // ================== INFRAESTRUCTURA ==================
    choice(name: 'INFRAESTRUCTURE_TYPE', choices: ['On-demand', 'Preemptible'], description: 'Tipo de infraestructura (demanda o preemtible)')

    // ================== RED / NETWORK ==================
    string(name: 'VPC_NETWORK', defaultValue: 'vpc-pe-01', description: 'Red VPC asociada')
    string(name: 'SUBNET', defaultValue: 'subnet-pe-01', description: 'Subred asignada')
    string(name: 'NETWORK_SEGMENT', defaultValue: '10.0.1.0/24', description: 'Segmento de red')
    string(name: 'INTERFACE', defaultValue: 'nic0', description: 'Interfaz de red primaria')
    choice(name: 'PRIVATE_IP', choices: ['true', 'false'], description: 'Habilitar IP privada')
    choice(name: 'PUBLIC_IP', choices: ['false', 'true'], description: 'Asignar IP pública')
    string(name: 'FIREWALL_RULES', defaultValue: 'allow-ssh', description: 'Reglas de firewall permitidas')

    // ================== SEGURIDAD Y SERVICIO ==================
    string(name: 'SERVICE_ACCOUNT', defaultValue: 'sa-plataforma@jenkins-terraform-demo-472920.iam.gserviceaccount.com', description: 'Cuenta de servicio utilizada por la VM')
    string(name: 'LABEL', defaultValue: 'app=demo', description: 'Etiqueta de la VM')
    choice(name: 'ENABLE_STARTUP_SCRIPT', choices: ['false', 'true'], description: 'Habilitar script de inicio')
    choice(name: 'ENABLE_DELETION_PROTECTION', choices: ['false', 'true'], description: 'Protección contra eliminación')
    choice(name: 'CHECK_DELETE', choices: ['false', 'true'], description: 'Confirmación antes de borrar la VM')

    // ================== INTEGRACIÓN Y TICKET ==================
    string(name: 'TICKET_JIRA', defaultValue: 'AJI-83', description: 'Ticket Jira asociado al despliegue')
}

stages {

    // 1) Validar y transicionar ticket jira
    stage('Validar y Transicionar Ticket Jira') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
            echo "Consultando estado actual del ticket ${params.TICKET_JIRA}..."
            def estado = sh(
              script: """bash -c 'curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" \
                -H "Accept: application/json" | jq -r ".fields.status.name // \\"Desconocido\\"" '""",
              returnStdout: true
            ).trim()
            echo "Estado actual: ${estado}"

            def transiciones = ["Tareas por hacer": "31"]
            env.ESTADO_TICKET = estado

            if (estado == "Tareas por hacer") {
              def transitionId = transiciones[estado]
              echo "Transicionando ticket ${params.TICKET_JIRA} a 'Done'..."
              def payloadTrans = groovy.json.JsonOutput.toJson([transition: [id: transitionId]])
              writeFile file: 'transicion.json', text: payloadTrans
              sh """curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" -X POST -H "Content-Type: application/json" --data @transicion.json "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" """
              echo "Ticket ${params.TICKET_JIRA} transicionado a Done."
            } else if (estado in ["Done", "Finalizado"]) {
              error("El ticket ${params.TICKET_JIRA} ya está '${estado}'.")
            } else {
              error("Ticket ${params.TICKET_JIRA} no elegible. Estado actual: '${estado}'.")
            }
          }
        }
      }
    }

    // 2) Notificar a Teams
    stage('Notificar a Teams') {
      steps {
        script {
          if (env.ESTADO_TICKET in ["Done"]) {
            def mensaje = "Ticket ${params.TICKET_JIRA} transicionado a Done. Pipeline en curso."
            def facts = [
              [name: "País", value: env.PAIS],
              [name: "Ambiente", value: params.ENVIRONMENT],
              [name: "Proyecto GCP", value: params.PROJECT_ID],
              [name: "VM", value: params.VM_NAME],
              [name: "Región/Zona", value: "${params.REGION}/${params.ZONE}"],
              [name: "Tipo VM", value: params.VM_TYPE],
              [name: "RAM (GB)", value: params.VM_MEMORY],
              [name: "Disco", value: "${params.DISK_SIZE} GB (${params.DISK_TYPE})"]
            ]
            def card = [
              '@type': 'MessageCard',
              '@context': 'http://schema.org/extensions',
              summary: "VM Linux: ${params.VM_NAME}",
              themeColor: "0076D7",
              sections: [[facts: facts, markdown: true]],
              potentialAction: [[
                '@type': "OpenUri",
                name: "Ver Build",
                targets: [[os: "default", uri: env.BUILD_URL]]
              ]]
            ]
            writeFile file: 'teams.json', text: groovy.json.JsonOutput.toJson(card)
            sh "curl -s -X POST -H 'Content-Type: application/json' --data @teams.json ${TEAMS_WEBHOOK}"
          }
        }
      }
    }

    // 3) Validación de variables
    stage('Validación de variables') {
      steps {
        script {
          echo "Validando el ambiente: ${params.ENVIRONMENT}"
          def backupEfectivo = params.DB_BACKUP_ENABLED

          if (params.ENVIRONMENT == 'Produccion') {
            if (params.DB_BACKUP_ENABLED == 'false') {
              echo "Producción detectada. Se fuerza DB_BACKUP_ENABLED = 'true'."
              backupEfectivo = 'true'
            } else {
              echo "Producción OK: DB_BACKUP_ENABLED ya es 'true'."
            }
          } else if (params.ENVIRONMENT in ['Desarrollo', 'Pre-productivo']) {
            echo "No producción. Se respeta DB_BACKUP_ENABLED=${params.DB_BACKUP_ENABLED}"
          } else {
            error("Ambiente inválido: ${params.ENVIRONMENT}")
          }

          env.BACKUP_EFFECTIVE = backupEfectivo
        }
      }
    }

    // 4) Crear Infraestructura en GCP
    stage('Crear Infraestructura en GCP') {
      steps {
        script {
          def attempt = 0
          def success = false
          while (attempt < env.MAX_RETRIES.toInteger() && !success) {
            attempt++
            echo "Intento #${attempt}: aprovisionando infraestructura..."
            try {
              sh 'echo "Simulación de creación de VM Linux..."'
              success = true
            } catch (err) {
              echo "Error en intento #${attempt}: ${err.getMessage()}"
              if (attempt == env.MAX_RETRIES.toInteger()) {
                error "Fallo tras ${env.MAX_RETRIES} intentos."
              } else {
                echo "Reintentando..."
              }
            }
          }
        }
      }
    }

    // 5) descripción jira
    stage('Descripción Jira') {
      steps {
        script {
          def texto = """
          País: ${env.PAIS}
          Ambiente: ${params.ENVIRONMENT}
          Proyecto GCP: ${params.PROJECT_ID}
          Región/Zona: ${params.REGION}/${params.ZONE}

          VM Linux:
          - Nombre: ${params.VM_NAME}
          - Procesador: ${params.PROCESSOR_TECH}
          - Tipo VM: ${params.VM_TYPE}
          - vCPUs: ${params.VM_CORES}
          - RAM: ${params.VM_MEMORY} GB
          - Disco: ${params.DISK_SIZE} GB (${params.DISK_TYPE})
          - SO: ${params.OS_TYPE}
          - Infraestructura: ${params.INFRAESTRUCTURE_TYPE}

          Red:
          - VPC/Subnet: ${params.VPC_NETWORK}/${params.SUBNET}
          - Segmento: ${params.NETWORK_SEGMENT}
          - IP Privada: ${params.PRIVATE_IP}
          - IP Pública: ${params.PUBLIC_IP}
          - Firewall: ${params.FIREWALL_RULES}
          """
          env.mensaje = notificationText
        }
      }
    }

    // 6) Crear ticket en Jira
    stage('Crear ticket en Jira') {
      when { expression { params.ENVIRONMENT == 'Produccion' } }
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
            def auth = "${JIRA_USER}:${JIRA_API_TOKEN}".bytes.encodeBase64().toString()
            def payload = [
              fields: [
                project: [key: env.PROYECT_JIRA],
                summary: env.TITULO_JIRA,
                description: [type: "doc", version: 1, content: [[type: "paragraph", content: [[type: "text", text: env.mensaje]]]]],
                issuetype: [id: env.ID_ISSUETYPE_JIRA]
              ]
            ]
            writeFile file: 'jira_create.json', text: groovy.json.JsonOutput.toJson(payload)
            sh """curl -s -X POST "${JIRA_API_URL}" -H "Authorization: Basic ${auth}" -H "Content-Type: application/json" --data @jira_create.json"""
          }
        }
      }
    }
// ================== 5) Imprimir Variables por Sección ==================
stage('Imprimir Variables por Sección') {
  steps {
    script {
      def backupEfectivo = env.BACKUP_EFFECTIVE?.trim() ? env.BACKUP_EFFECTIVE : params.DB_BACKUP_ENABLED

      // ================== VARIABLES OCULTAS ==================
      def ocultas = [
        PAIS                 : 'PE',
        SISTEMA_OPERATIVO_BASE: 'Linux',
        SNAPSHOT_ENABLED     : 'true',
        SNAPSHOT_VM          : 'snap_vm_01',
        SNAPSHOT_SO          : 'snap_os_01',
        SNAPSHOT_DISK        : 'snap_disk_01',
        LABEL                : 'vm-template',
        ENABLE_STARTUP_SCRIPT: 'true'
      ]

      // ================== VARIABLES GCP ==================
      def gcp = [
        PROJECT_ID  : params.PROJECT_ID,
        REGION      : params.REGION,
        ZONE        : params.ZONE,
        ENVIRONMENT : params.ENVIRONMENT
      ]

      // ================== CONFIGURACIÓN DE VM ==================
      def vm = [
        VM_NAME              : params.VM_NAME,
        PROCESSOR_TECH       : params.PROCESSOR_TECH,
        VM_TYPE              : params.VM_TYPE,
        VM_CORES             : params.VM_CORES,
        VM_MEMORY            : params.VM_MEMORY,
        OS_TYPE              : params.OS_TYPE,
        DISK_SIZE            : params.DISK_SIZE,
        DISK_TYPE            : params.DISK_TYPE,
        INFRAESTRUCTURE_TYPE : params.INFRAESTRUCTURE_TYPE,
        AUTO_DELETE_DISK     : params.AUTO_DELETE_DISK
      ]

      // ================== RED / NETWORK ==================
      def red = [
        VPC_NETWORK     : params.VPC_NETWORK,
        SUBNET          : params.SUBNET,
        NETWORK_SEGMENT : params.NETWORK_SEGMENT,
        INTERFACE       : params.INTERFACE,
        PRIVATE_IP      : params.PRIVATE_IP,
        PUBLIC_IP       : params.PUBLIC_IP,
        FIREWALL_RULES  : params.FIREWALL_RULES
      ]

      // ================== SEGURIDAD / OPERACIÓN ==================
      def seguridad = [
        SERVICE_ACCOUNT           : params.SERVICE_ACCOUNT,
        ENABLE_STARTUP_SCRIPT     : params.ENABLE_STARTUP_SCRIPT,
        ENABLE_DELETION_PROTECTION: params.ENABLE_DELETION_PROTECTION,
        CHECK_DELETE              : params.CHECK_DELETE,
        LABEL                     : params.LABEL,
        TICKET_JIRA               : params.TICKET_JIRA
      ]


      def printSection = { titulo, mapa ->
        echo "================= ${titulo} ================="
        mapa.keySet().sort().each { k -> echo "${k}: ${mapa[k]}" }
      }

      printSection('DEFAULT (Ocultas)', ocultas)
      printSection('GCP', gcp)
      printSection('VM CONFIG', vm)
      printSection('RED / NETWORK', red)
      printSection('SEGURIDAD / OPERACIÓN', seguridad)
    }
  }
}

post {
  success {
    echo 'Pipeline ejecutado correctamente.'
  }
  failure {
    echo 'Error al ejecutar el pipeline.'
  }
  always {
    echo "==================== FIN DE PIPELINE ===================="
  }
}
