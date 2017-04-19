# HADOOP_OPENSHIFT

# SYSTEM COMPONENTS:
    Pre-Configured Terraform and Ansible Script to deploy Openshift on AWS.
    Docker Image + Openshift templates.
    Packages: dnsmasq, serf, openssh-server, default-jdk.
  
 # Aws setup & Openshift Installation
      Utilized pre-configured terraform+ansible scripts to build the test environment. The setup includes 4 hosts, and one micro and three       large t2 instances. The micro instance is used for the bastion host and the three large nodes are the cluster nodes for Openshift.
    Link -> https://www.codeproject.com/Articles/1168687/Get-up-and-running-with-OpenShift-on-AWS

# Docker File will
    ▪ Install required packages - dnsmasq, serf, openssh-server, default-jdk.
    ▪ Upload config files for all installed packages and generate ssh keys.
    ▪ Create a Hadoop user – hduser.
    ▪ Download and setup Hadoop.
    ▪ Copy required start up scripts to the containers.
    ▪ Format HDFS.
    ▪ Expose the Ports required by the services and Hadoop.
  
 # Startup Scripts highlights:
      ▪ Scripts to start serf agent and dnsmasq services.
      ▪ Script to update /etc/hosts file.
      ▪ Script to update Hadoop slaves file.
      ▪ Script to update Start Hadoop Cluster
      ▪ Scripts to run import files and test MapReduce
# OPENSHIFT CONFIGURATION
    oc set env dc/docker-registry -n default REGISTRY_MIDDLEWARE_REPOSITORY_OPENSHIFT_ACCEPTSCHEMA2=true
    oadm policy add-scc-to-user anyuid -z default
    oc edit scc anyuid       ## add your project's system account to this file
    systemctl restart origin-master.service
    
    basically we are setting up to run privelaged containters; Openshift by default doesn't allow privelaged mode.

# OPENSHIFT TEMPLATES
    # Master:
      ▪ Commands – start serf agent, start ssh service ; 
      ▪ Defined ports and protocols.
      ▪ Set security context as to run images as privileged containers.

    # Slave:
    ▪ Commands - Start serf agent. Start ssh service
    ▪ Commands - Start Script to update hosts file
    ▪ Defined ports and protocols.  
    ▪ Set security context to run images as privileged containers.
    ▪ Set Replicas factor to three.
    
# Assumptions, limitations and Issues:
    ▪ The Containers are run in privilege mode so that ssh function’s properly.
    ▪ All Hadoop related commands will only work for hduser. Use – su hduser before starting the Hadoop cluster.
    ▪ Security context for service account set to Anyuid policy for elevated privileges.
    ▪ Due to Image pull back issues, unable to use local images from Openshift master.
    ▪ Commands part of CMD line in Docker file were not being executed, moved them to the Openshift template.
    ▪ Utilized pre-configured terraform and Ansible scripts for Openshift installation due to complications during install.
    ▪ Project priority - optimize the Docker file builds and create Openshift templates.    
    
# Future optimization considerations:
    ▪ Split the Docker image build into layers.
    ▪ Setup Port Forwarding to enable Hadoop Web GUI access.
    ▪ Implement log aggregation and health checks.
    ▪ Consider changing port settings from TCP to UDP for serf related port.
    ▪ Tighten Security context settings in Openshift.
    ▪ Explore running containers in non-privileged mode.
▪ Configure resource limits.
