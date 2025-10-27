pipeline {
    agent any

    parameters {
        // Variables ocultas (en orden)
        password(name: 'JIRA_API_TOKEN', defaultValue: '', description: 'Token de autenticación de Jira')
        string(name: 'TEAMS_WEBHOOK', defaultValue: '', description: 'Webhook para notificación a Teams')
        string(name: 'JIRA_API_URL', defaultValue: 'https://tu_jira.atlassian.net/rest/api/2/issue/', description: 'URL base del API de Jira')

        // Variables visibles (en orden)
        string(name: 'PROJECT_ID', defaultValue: '', description: 'ID del proyecto de GCP')
        string(name: 'REGION', defaultValue: '', description: 'Región de despliegue')
        string(name: 'INSTANCE_NAME', defaultValue: 'sqlserver-instance', description: 'Nombre de la instancia')
        string(name: 'DATABASE_VERSION', defaultValue: 'SQLSERVER_2019_STANDARD', description: 'Versión de la base de datos')
        string(name: 'ROOT_PASSWORD', defaultValue: '', description: 'Contraseña del usuario root')
        string(name: 'TICKET_JIRA', defaultValue: '', description: 'Número del ticket Jira asociado')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Acción a ejecutar con Terraform')
    }

    stages {

        stage('Impresión de variables') {
            steps {
                script {
                    echo "----------------------------------------"
                    echo " Variables ocultas"
                    echo "----------------------------------------"
                    echo "JIRA_API_TOKEN: Valor oculto"
                    echo "TEAMS_WEBHOOK: ${params.TEAMS_WEBHOOK}"
                    echo "JIRA_API_URL: ${params.JIRA_API_URL}"

                    echo "----------------------------------------"
                    echo " Variables visibles"
                    echo "----------------------------------------"
                    echo "PROJECT_ID: ${params.PROJECT_ID}"
                    echo "REGION: ${params.REGION}"
                    echo "INSTANCE_NAME: ${params.INSTANCE_NAME}"
                    echo "DATABASE_VERSION: ${params.DATABASE_VERSION}"
                    echo "ROOT_PASSWORD: Valor oculto"
                    echo "TICKET_JIRA: ${params.TICKET_JIRA}"
                    echo "ACTION: ${params.ACTION}"
                }
            }
        }

        stage('Validación de Parámetros Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        def auth = java.util.Base64.encoder.encodeToString("${JIRA_USER}:${JIRA_API_TOKEN}".getBytes("UTF-8"))

                        echo "==============================================="
                        echo "   Validando estado del ticket ${params.TICKET_JIRA}"
                        echo "==============================================="

                        // 1. Consultar estado actual
                        def response = sh(script: """
                            curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" \
                            -H "Authorization: Basic ${auth}" \
                            -H "Accept: application/json"
                        """, returnStdout: true).trim()

                        def issueData = new groovy.json.JsonSlurper().parseText(response)
                        def estadoActual = issueData?.fields?.status?.name ?: "Desconocido"

                        echo "Estado actual del ticket: ${estadoActual}"

                        // 2. Validar si ya está finalizado
                        if (estadoActual.toLowerCase() in ["done", "finalizado", "closed", "cerrado"]) {
                            error("El ticket ${params.TICKET_JIRA} ya está en estado '${estadoActual}'. No se puede continuar con la ejecución.")
                        }

                        // 3. Si está en curso, pasarlo automáticamente a finalizado
                        if (estadoActual.toLowerCase() == "en curso") {
                            echo "El ticket está en curso. Procediendo a cerrarlo automáticamente..."

                            def transitionsResp = sh(script: """
                                curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \
                                -H "Authorization: Basic ${auth}" \
                                -H "Accept: application/json"
                            """, returnStdout: true).trim()

                            def transitions = new groovy.json.JsonSlurper().parseText(transitionsResp)
                            def finalizadoTransition = transitions?.transitions?.find { it.name.toLowerCase().contains("finalizado") || it.name.toLowerCase().contains("done") }

                            if (finalizadoTransition) {
                                sh """
                                    curl -s -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \
                                    -H "Authorization: Basic ${auth}" \
                                    -H "Content-Type: application/json" \
                                    -d '{ "transition": { "id": "${finalizadoTransition.id}" } }'
                                """
                                echo "Ticket ${params.TICKET_JIRA} movido a estado 'Finalizado'."

                                def ticketJsonStr = new groovy.json.JsonOutput.toJson([text: "Ticket ${params.TICKET_JIRA} pasó de 'En curso' a 'Finalizado' automáticamente."])
                                echo "Ticket JSON: ${ticketJsonStr}"
                                writeFile file: 'teams_message.json', text: ticketJsonStr
                                sh "curl -H 'Content-Type: application/json' -d @teams_message.json ${TEAMS_WEBHOOK}"
                            } else {
                                error("No se encontró transición válida a 'Finalizado' para el ticket ${params.TICKET_JIRA}.")
                            }
                        } else {
                            echo "El ticket ${params.TICKET_JIRA} no está en curso ni finalizado (estado: ${estadoActual}). Continuando..."
                        }
                    }
                }
            }
        }

        stage('Resumen Pre-Despliegue') {
            steps {
                echo "Validaciones completadas. Listo para proceder con la acción: ${params.ACTION}"
            }
        }

        // stage('Terraform Init') {
        //     steps {
        //         echo "Inicializando Terraform..."
        //         sh 'terraform init'
        //     }
        // }

        // stage('Terraform Plan') {
        //     when {
        //         expression { params.ACTION == 'plan' }
        //     }
        //     steps {
        //         echo "Ejecutando Terraform Plan..."
        //         sh "terraform plan -var='project_id=${params.PROJECT_ID}' -var='region=${params.REGION}' -var='instance_name=${params.INSTANCE_NAME}'"
        //     }
        // }

        // stage('Terraform Apply') {
        //     when {
        //         expression { params.ACTION == 'apply' }
        //     }
        //     steps {
        //         echo "Ejecutando Terraform Apply..."
        //         sh "terraform apply -auto-approve -var='project_id=${params.PROJECT_ID}' -var='region=${params.REGION}'"
        //     }
        // }

        // stage('Terraform Destroy') {
        //     when {
        //         expression { params.ACTION == 'destroy' }
        //     }
        //     steps {
        //         echo "Ejecutando Terraform Destroy..."
        //         sh "terraform destroy -auto-approve"
        //     }
        // }
    }

    post {
        success {
            echo "Pipeline finalizado correctamente."
        }
        failure {
            echo "Pipeline fallido. Revisar logs de ejecución."
        }
    }
}
