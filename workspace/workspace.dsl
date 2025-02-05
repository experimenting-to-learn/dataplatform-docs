/*
 * This is a combined version of the following workspaces:
 *
*/
workspace "자율주행 빅데이터 플랫폼" "The workspace to illustrate the system architecture of Autonomous Driving Bigdata Platform." {
    !docs docs
    !adrs adrs

    # element is only available on the Structurizr cloud service/on-premises installation/Lite
    model {

        properties {
            "structurizr.groupSeparator" "/"
        }

        group "Stakeholders" {
            dataConsumer = person "Data Consumer" "A consumer who are needed a data in various context." "Person"
        }

        group "Distributed Datasets" {
            enterpriseERP = person "ERP" "Traditional type of dataset in enterprise grade." "Data Sources"
            dataLake = person "Data Lake" "Unstructured or semi-structured dataset" "Data Sources"
            dataWarehouse = person "Data Warehouse" "Structured dataset." "Data Sources"

            group "Hycon Data Pipeline" {

            hyconDataGeneration = person "Generated Data by Scenario Directory" "Autonomous Driving Data for Machine Learning"
            
            hyconDataPipeline = softwaresystem "Data Pipeline" "An autonomous driving dataset generated from scenarios provided by the consortium." {
                tags "Hycon"
                 
                hp_autonomousDataStore = container "Autonomous Data Store" "Database" {
                    tags "Database" "Hycon"
                }
                hp_metadataStore = container "Metadata Store" "Database" {
                    tags "Database" "Hycon"
                }
                hp_metadataExtractor = container "Metadata Extraction" "API Server" {
                    tags "Hycon"
                }
                hp_anontmization = container "Anontmization" "API Server" {
                    tags "Hycon"
                }
                hp_visualization = container "Visualization" "API Server" {
                    tags "Hycon"
                }
            }

            hyconDataGeneration -> hp_autonomousDataStore "Transfer Data"
            hp_metadataExtractor -> hp_autonomousDataStore "Extract metadata(by file)"
            hp_metadataExtractor -> hp_anontmization "Anonymization"
            hp_anontmization -> hp_visualization "Processing for Visualization"
            hp_visualization -> hp_metadataStore "Load Data"
        }
        }

        

        group "Int2 Data Fabric" {

            dataFabric = softwaresystem "Data Fabric" "Orchestrates distributed datasets owned by individual entities, enabling information retrieval and managing the data lifecycle." "Int2 Data Fabric" {
                !docs data-fabric-core/docs
                !adrs data-fabric-core/adrs
            #    dataTailoringEngine =  container "Data Tailoring Engine" "Provides a mechanism to orchestrate the data with the governances." ""

                group "Client-side" {
                    jotter = container "Web Application" "Serverless nextjs" {
                        tags "Web Browser"
                    }
                }

                group "Server-side" {

                    group "API Gateway Service" {
                        fabricApiProvider = container "API Service" "API Gateway Managed Service"
                    }

                    group "Knowledge Service" {
                        knowledgeSlipbox = container "Knowledge Graph App" "Provides" "Container: Serverless Java or Typescript Application" {
                            knowledgeWeaver = component "Knowledge Weaver" "Knowledge Weaver"
                            knowledgeSlipboxApiProvider = component "Knowledge Slipbox Api Provider" "Knowledge Graph"
                        }

                        knowledgeGraphDatabase = container "Knowledge Graph Database" "DB: Neo4j or AWS Neptune" {
                            tags "Database" "Graph Database"
                        }
                    }

                    group "Metadata Service" {

                        activeMetadata = container "Metadata App" "Active Metadata" {
                            tags "Active Metadata"
                            metaGin = component "Meta Gin" "Metadata Analyzer" "Component: Spring bean" {
                                tags "Active Metadata" 
                            }
                            oddSpecification = component "Data Catalog Builder" "Component: Spring bean" {
                                tags "Active Metadata"
                            }
                            fabricDataCatalog = component "Fabric Data Catalog" "Component: Spring bean" {
                                tags "Active Metadata"
                            }
                        }
                        
                        activeMetadataDb = container "Metadata Database" "DB: AWS Aurora Postgrsql" {
                            tags "Database" "Active Metadata"
                        }
                    }
                    
                }

                fabricBroker = container "Data Source Gateway" "Manage data pipeline between distburited data source and Data Fabric in secure." "Container: Java Application"
            }
        }

        group "Relation between Hycon Data Pipeline and Int2 Data Fabric" {
            fabricBroker -> hp_autonomousDataStore
            fabricBroker -> hp_metadataStore
        }

        dataConsumer -> fabricApiProvider
        dataConsumer -> jotter

        knowledgeWeaver -> knowledgeGraphDatabase "build Local Knowledge Graph"
        knowledgeWeaver -> metaGin 
        
        knowledgeSlipboxApiProvider -> knowledgeGraphDatabase "fetch"

        # relationships between people and software systems
        fabricBroker -> enterpriseERP 
        fabricBroker -> dataLake 
        fabricBroker -> dataWarehouse 

        metaGin -> fabricBroker
        metaGin -> fabricDataCatalog "analyze"
        metaGin -> oddSpecification

        activeMetadata -> activeMetadataDb

        oddSpecification -> fabricDataCatalog 
        oddSpecification -> fabricBroker 

        fabricApiProvider -> knowledgeSlipboxApiProvider 
        fabricApiProvider -> metaGin 
        
        jotter -> fabricApiProvider

        integration = deploymentEnvironment "Integration" {
            deploymentNode "Hycon Data Pipeline" {
                containerInstance hp_autonomousDataStore
                containerInstance hp_metadataStore
                containerInstance hp_metadataExtractor
                containerInstance hp_anontmization
                containerInstance hp_visualization
            }
            deploymentNode "Intellectus Data Fabric" {
                containerInstance fabricBroker
                deploymentNode "Metadata Service" {
                    containerInstance activeMetadata
                    containerInstance activeMetadataDb
                }
                deploymentNode "Knowledge Service" {
                    containerInstance knowledgeSlipbox
                    containerInstance knowledgeGraphDatabase
                }
                deploymentNode "API Gateway Service" {
                    containerInstance fabricApiProvider
                }
            }
        }
    }

    views {
        properties {
            "c4plantuml.elementProperties" "true"
            # with c4plantuml.tags set as true, it's enable to apply custom styles 
            "c4plantuml.tags" "true" 
            "generatr.style.colors.primary" "#485fc7"
            "generatr.style.colors.secondary" "#ffffff"
            
            // "generatr.style.faviconPath" "site/favicon.ico"
            // "generatr.style.logoPath" "site/logo.png"
        }

        systemlandscape "SystemLandscape" {
            include *
            autoLayout
        }

        systemcontext dataFabric "SystemContext" {
            include *
            animation {
               dataFabric
            }
            autoLayout
        }

        container dataFabric "Containers" {
            include *
            autoLayout
        }

        dynamic knowledgeSlipbox "LocalKnowledgeGraph" "로컬 지식그래프 아키텍처" {
            metaGin -> fabricBroker "access data source via Broker"
            knowledgeWeaver -> metaGin "weave Knowledge from Metadata"
            knowledgeWeaver -> knowledgeGraphDatabase "build Local Knowledge Graph"
            knowledgeSlipboxApiProvider -> knowledgeGraphDatabase "fetch"
            autoLayout
            description "로컬 지식그래프 아키텍처"
        }

        dynamic activeMetadata "WorkflowBuildingLocalKnowledgeGraph" "Local Knowledge Graph 구축 흐름도" {
            fabricDataCatalog -> metaGin "analyze"
            metaGin -> knowledgeWeaver "weave Knowledge from Metadata"
            knowledgeWeaver -> knowledgeGraphDatabase "build Local Knowledge Graph"
            autoLayout lr
            description "workflow to build Local Knowledge Graph"
        }

        dynamic activeMetadata "WorkflowBuildingFabricDataCatalog" "Fabric Data Catalog 구축 흐름도" {
            fabricBroker -> metaGin
            metaGin -> oddSpecification "analyze"
            oddSpecification -> fabricDataCatalog "convert"
            
            autoLayout lr
            description "workflow to build Local Knowledge Graph"
        }

        dynamic knowledgeSlipbox "KnowledgeCatalog" "Knowledge Catalog 개념도" {
            metaGin -> fabricDataCatalog "fetch"
            knowledgeSlipboxApiProvider -> knowledgeGraphDatabase "fetch"
            fabricApiProvider -> knowledgeSlipboxApiProvider 
            fabricApiProvider -> metaGin
            jotter -> fabricApiProvider "use as Knowledge Catalog"
            autoLayout lr
            description "Knowledge Catalog 개념도"
        }

        deployment * integration "HeighLevelDesign " {
            include *
            autoLayout
        }

        styles {
            
            element "Software System" {
                background #1168bd
                color #ffffff
            }

            element "Hycon" {
                background #FFD470
                color #4a4a4a
            }

            element "Web Browser" {
                shape WebBrowser
            }

            element "Database" {
                shape Cylinder
            }

            element "Customer" {
                background #08427b
            }
            element "Bank Staff" {
                background #999999
            }


            element "Container" {
                background #438dd5
                color #ffffff
            }
            
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Knowledge Graph Database" {
                shape Cylinder
            }
        }
    }
}