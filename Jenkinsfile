pipeline {
    agent any

    environment {
        PAIS = 'PE'
        SISTEMA_OPERATIVO_BASE = 'Linux'
        SNAPSHOT_ENABLED = 'true'
        SNAPSHOT_VM = 'snap_vm_01'
        SNAPSHOT_SO = 'snap_os_01'
        SNAPSHOT_DISK = 'snap_disk_01'
        LABEL = 'vm-template'
        ENABLE_STARTUP_SCRIPT = 'true'
        JIRA_API_URL = "https://bancoripley1.atlassian.net/rest/api/3/issue/"
        TICKET_JIRA = "AJI-83"
        TEAMS_WEBHOOK = "https://accenture.webhook.office.com/webhookb2/8fb63984-6f5f-4c2a-a6d3-b4fce2feb8ee@e0793d39-0939-496d-b129-198edd916feb/IncomingWebhook/334818fae3a84ae484512967d1d3f4f1/b08cc148-e951-496b-9f46-3f7e35f79570/V27mobtZgWmAzxIvjHCY5CMAFKPZptkEnQbT5z7X84QNQ1"
        // intentos máximos para crear instancia
        MAX_RETRIES = 2
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
        string(name: 'PROYECT_ID', defaultValue: '', description: 'ID del proyecto en GCP')
        string(name: 'REGION', defaultValue: 'us-central1', description: 'Región')
        string(name: 'ZONE', defaultValue: 'us-central1-a', description: 'Zona')
        choice(name: 'ENVIRONMENT', choices: ['desarrollo-1', 'pre-productivo-2', 'produccion-3'], description: 'Ambiente')
        string(name: 'VM_NAME', defaultValue: 'vm-pe-linux', description: 'Nombre VM')
        choice(name: 'PROCESSOR_TECH', choices: ['n2', 'e2'], description: 'Procesador')
        choice(name: 'VM_TYPE', choices: ['n2-standard', 'e2-standard'], description: 'Tipo VM')
        string(name: 'VM_CORES', defaultValue: '2', description: 'vCPUs')
        string(name: 'VM_MEMORY', defaultValue: '8', description: 'RAM GB')
        choice(name: 'OS_TYPE', choices: ['linux-ubuntu-22', 'linux-ubuntu-20', 'linux-debian-12'], description: 'OS')
        string(name: 'DISK_SIZE', defaultValue: '100', description: 'Disco GB')
        choice(name: 'DISK_TYPE', choices: ['pd-ssd', 'pd-balanced', 'pd-standard'], description: 'Tipo disco')
        choice(name: 'INFRAESTRUCTURE_TYPE', choices: ['On-demand', 'Preemptible'], description: 'Infraestructura')
        string(name: 'VPC_NETWORK', defaultValue: 'vpc-pe-01', description: 'VPC')
        string(name: 'SUBNET', defaultValue: 'subnet-pe-01', description: 'Subred')
        string(name: 'NETWORK_SEGMENT', defaultValue: '10.0.1.0/24', description: 'Segmento red')
        string(name: 'INTERFACE', defaultValue: 'nic0', description: 'Interfaz')
        choice(name: 'PRIVATE_IP', choices: ['true', 'false'], description: 'IP Privada')
        choice(name: 'PUBLIC_IP', choices: ['false', 'true'], description: 'IP Pública')
        string(name: 'FIREWALL_RULES', defaultValue: 'allow-ssh', description: 'Firewall')
        string(name: 'SERVICE_ACCOUNT', defaultValue: 'sa-plataforma@jenkins-terraform-demo-472920.iam.gserviceaccount.com', description: 'Cuenta Servicio')
        string(name: 'LABEL', defaultValue: 'app=demo', description: 'Label')
        choice(name: 'ENABLE_STARTUP_SCRIPT', choices: ['false', 'true'], description: 'Startup script')
        choice(name: 'ENABLE_DELETION_PROTECTION', choices: ['false', 'true'], description: 'Protección eliminación')
        choice(name: 'CHECK_DELETE', choices: ['false', 'true'], description: 'Confirmación borrado')
        choice(name: 'AUTO_DELETE_DISK', choices: ['true', 'false'], description: 'Auto delete disk')
        string(name: 'TICKET_JIRA', defaultValue: 'AJI-83', description: 'Ticket Jira')
    }

    stages {

        stage('Mostrar Variables Ocultas y Visibles') {
            steps {
                script {
                    echo "================== Variables Ocultas =================="
                    echo "PAIS: ${env.PAIS}"
                    echo "SISTEMA_OPERATIVO_BASE: ${env.SISTEMA_OPERATIVO_BASE}"
                    echo "SNAPSHOT_ENABLED: ${env.SNAPSHOT_ENABLED}"
                    echo "SNAPSHOT_VM: ${env.SNAPSHOT_VM}"
                    echo "SNAPSHOT_SO: ${env.SNAPSHOT_SO}"
                    echo "SNAPSHOT_DISK: ${env.SNAPSHOT_DISK}"
                    echo "LABEL: ${env.LABEL}"
                    echo "ENABLE_STARTUP_SCRIPT: ${env.ENABLE_STARTUP_SCRIPT}"

                    echo "================== Variables Visibles =================="
                    echo "PROYECT_ID: ${params.PROYECT_ID}"
                    echo "REGION: ${params.REGION}"
                    echo "ZONE: ${params.ZONE}"
                    echo "ENVIRONMENT: ${params.ENVIRONMENT}"
                    echo "VM_NAME: ${params.VM_NAME}"
                    echo "PROCESSOR_TECH: ${params.PROCESSOR_TECH}"
                    echo "VM_TYPE: ${params.VM_TYPE}"
                    echo "VM_CORES: ${params.VM_CORES}"
                    echo "VM_MEMORY: ${params.VM_MEMORY}"
                    echo "OS_TYPE: ${params.OS_TYPE}"
                    echo "DISK_SIZE: ${params.DISK_SIZE}"
                    echo "DISK_TYPE: ${params.DISK_TYPE}"
                    echo "INFRAESTRUCTURE_TYPE: ${params.INFRAESTRUCTURE_TYPE}"
                    echo "VPC_NETWORK: ${params.VPC_NETWORK}"
                    echo "SUBNET: ${params.SUBNET}"
                    echo "NETWORK_SEGMENT: ${params.NETWORK_SEGMENT}"
                    echo "INTERFACE: ${params.INTERFACE}"
                    echo "PRIVATE_IP: ${params.PRIVATE_IP}"
                    echo "PUBLIC_IP: ${params.PUBLIC_IP}"
                    echo "FIREWALL_RULES: ${params.FIREWALL_RULES}"
                    echo "SERVICE_ACCOUNT: ${params.SERVICE_ACCOUNT}"
                    echo "LABEL: ${params.LABEL}"
                    echo "ENABLE_STARTUP_SCRIPT: ${params.ENABLE_STARTUP_SCRIPT}"
                    echo "ENABLE_DELETION_PROTECTION: ${params.ENABLE_DELETION_PROTECTION}"
                    echo "CHECK_DELETE: ${params.CHECK_DELETE}"
                    echo "AUTO_DELETE_DISK: ${params.AUTO_DELETE_DISK}"
                    echo "TICKET_JIRA: ${params.TICKET_JIRA}"
                }
            }
        }

        stage('Validación de Parámetros') {
            steps {
                script {
                    def errores = []
                    if (!params.SUBNET?.trim()) errores.add("SUBNET no puede estar vacío")
                    if (!params.NETWORK_SEGMENT?.trim()) errores.add("NETWORK_SEGMENT no puede estar vacío")
                    if (errores) {
                        errores.each { echo it }
                        error("Validación de parámetros fallida")
                    }
                }
            }
        }

        stage('Resumen Pre-Despliegue') {
            steps {
                script {
                    echo "================================================"
                    echo " RESUMEN DE CONFIGURACIÓN "
                    echo "================================================"
                    echo "Sistema Operativo Base: ${env.SISTEMA_OPERATIVO_BASE}"
                    echo "Tipo de Procesador: ${params.PROCESSOR_TECH}"
                    echo "Memoria RAM (GB): ${params.VM_MEMORY}"
                    echo "Disco (GB): ${params.DISK_SIZE}"
                    echo "Infraestructura: ${params.INFRAESTRUCTURE_TYPE}"
                }
            }
        }

        stage('Validar y Transicionar Ticket Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {

                        def estado = sh(
                            script: """bash -c '
                                curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                                -X GET "${JIRA_API_URL}${TICKET_JIRA}" \
                                -H "Accept: application/json" \
                                | jq -r ".fields.status.name // \\"Desconocido\\""
                            '""",
                            returnStdout: true
                        ).trim()

                        env.ESTADO_TICKET = estado
                        echo "Estado actual del ticket: ${estado}"

                        if (estado == "Tareas por hacer") {
                            def payloadTrans = groovy.json.JsonOutput.toJson([transition: [id: "31"]])
                            writeFile file: 'transicion.json', text: payloadTrans
                            sh """curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                                 -X POST -H "Content-Type: application/json" \
                                 --data @transicion.json \
                                 "${JIRA_API_URL}${TICKET_JIRA}/transitions" """
                        } else if (estado in ["Done", "Finalizado"]) {
                            error("El ticket ${TICKET_JIRA} ya está en estado '${estado}'. No se puede volver a marcar.")
                        }
                    }
                }
            }
        }

        stage('Crear Infraestructura en GCP') {
            steps {
                script {
                    def attempt = 0
                    def success = false

                    while (attempt < env.MAX_RETRIES.toInteger() && !success) {
                        attempt++
                        echo "Intento #${attempt}: simulando creación de infraestructura..."

                        try {
                            // Simulación de fallo (puedes reemplazar 'false' con el comando real)
                            sh 'false'

                            echo "Simulación exitosa (esto no debería ocurrir con 'false')."
                            success = true
                        } catch (err) {
                            echo "Error en el intento #${attempt}: ${err.getMessage()}"
                            if (attempt == env.MAX_RETRIES.toInteger()) {
                                error "Simulación fallida después de ${env.MAX_RETRIES} intentos."
                            } else {
                                echo "Reintentando..."
                            }
                        }
                    }
                }
            }
        }

        stage('Notificar a Teams') {
            steps {
                script {
                    if (env.ESTADO_TICKET in ["Done", "Finalizado"]) {
                        def mensajeError = "El ticket ${TICKET_JIRA} ya estaba '${env.ESTADO_TICKET}'. No se realizó nueva transición ni despliegue."
                        def payloadError = groovy.json.JsonOutput.toJson([ text: mensajeError ])
                        writeFile file: 'teams_error.json', text: payloadError
                        sh "curl -s -X POST -H 'Content-Type: application/json' --data @teams_error.json ${TEAMS_WEBHOOK}"
                        error("Pipeline detenido: ticket ya finalizado.")
                    }

                    def mensajeTeams = """Ticket ${TICKET_JIRA} cambió automáticamente de 'Tareas por hacer' a 'Finalizado (Done)'.

Pipeline completado correctamente.

Instancia de máquina virtual creada con los siguientes detalles:"""

                    def facts = [
                        [ name: "Pais", value: env.PAIS ],
                        [ name: "Ambiente", value: params.ENVIRONMENT ],
                        [ name: "Proyecto GCP", value: params.PROYECT_ID ],
                        [ name: "Nombre de la VM", value: params.VM_NAME ],
                        [ name: "Región/Zona", value: "${params.REGION}/${params.ZONE}" ],
                        [ name: "Tipo de Máquina", value: params.VM_TYPE ],
                        [ name: "vCPUs / RAM", value: "${params.VM_CORES} / ${params.VM_MEMORY} GB" ],
                        [ name: "Disco", value: "${params.DISK_SIZE} GB (${params.DISK_TYPE})" ],
                        [ name: "OS", value: params.OS_TYPE ],
                        [ name: "Red", value: "${params.VPC_NETWORK} / ${params.SUBNET}" ]
                    ]

                    def card = [
                        '@type': 'MessageCard',
                        '@context': 'http://schema.org/extensions',
                        text: mensajeTeams,
                        summary: "Nueva VM creada",
                        themeColor: "0076D7",
                        sections: [[
                            activitySubtitle: "Ticket Jira: ${params.TICKET_JIRA}",
                            facts: facts,
                            markdown: true
                        ]],
                        potentialAction: [[
                            '@type': "OpenUri",
                            name: "Ver Build",
                            targets: [[ os: "default", uri: env.BUILD_URL ?: "" ]]
                        ]]
                    ]

                    def payload = groovy.json.JsonOutput.toJson(card)
                    writeFile file: 'teams_final.json', text: payload
                    sh "curl -s -X POST -H 'Content-Type: application/json' --data @teams_final.json ${TEAMS_WEBHOOK}"
                }
            }
        }

        stage('Descripción Jira') {
            steps {
                script {
                    env.mensaje = """
                    País: ${env.PAIS}
                    VM: ${params.VM_NAME}
                    Ambiente: ${params.ENVIRONMENT}
                    Proyecto: ${params.PROYECT_ID}
                    Región/Zona: ${params.REGION}/${params.ZONE}
                    Tipo de VM: ${params.VM_TYPE}
                    vCPUs: ${params.VM_CORES}
                    RAM: ${params.VM_MEMORY} GB
                    Disco: ${params.DISK_SIZE} GB (${params.DISK_TYPE})
                    OS: ${params.OS_TYPE}
                    VPC/Subnet: ${params.VPC_NETWORK} / ${params.SUBNET}
                    IP Pública: ${params.PUBLIC_IP}
                    Firewall: ${params.FIREWALL_RULES}
                    """
                }
            }
        }

        stage('Crear Ticket en Jira') {
            when { expression { params.ENVIRONMENT == 'produccion-3' } }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {

                        def payloadMap = [
                            fields: [
                                project: [ key: "PRJ" ],
                                summary: "Nueva VM desplegada - ${params.VM_NAME}",
                                description: [
                                    type: "doc",
                                    version: 1,
                                    content: [[
                                        type: "paragraph",
                                        content: [[type: "text", text: env.mensaje]]
                                    ]]
                                ],
                                issuetype: [ name: "Task" ]
                            ]
                        ]

                        def payloadJson = groovy.json.JsonOutput.toJson(payloadMap)
                        sh """
                            curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                            -X POST -H "Content-Type: application/json" \
                            -d '${payloadJson}' ${JIRA_API_URL}
                        """
                    }
                }
            }
        }
    }

    post {
        success { echo "Pipeline ejecutado correctamente." }
        failure { echo "Error al ejecutar el pipeline." }
        always {
            echo "================================================"
            echo " FIN DE LA EJECUCIÓN "
            echo " Fecha: ${new Date()}"
            echo "================================================"
        }
    }
}

