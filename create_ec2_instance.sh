source conf

CLUSTER=""
CONFIG=""
PROFILE=""
ENTRY_POINT=""

for i in "$@"; do
    case $i in
    cluster=*)
        CLUSTER="${i#*=}"
        ;;
    policy=*)
        POLICY="${i#*=}"
        ;;
    config=*)
        CONFIG="${i#*=}"
        ;;
    key=*)
        KEY="${i#*=}"
        ;;
    instance=*)
        INSTANCE_TYPE="${i#*=}"
        ;;
    region=*)
        REGION="${i#*=}"
        ;;
    entry_point=*)
        ENTRY_POINT="${i#*=}"
        ;;
    *) ;;

    esac
done

# echo $CLUSTER
# echo $POLICY
# echo $CONFIG
# echo $KEY
# echo $INSTANCE_TYPE
# echo $REGION
# echo $ENTRY_POINT

function ecs_configure() {
    echo "Configuring Cluster"
    ./ecs-cli-linux-amd64-latest configure --cluster $CLUSTER --region $REGION --default-launch-type $LAUNCH_TYPE --config-name $CONFIG

    echo "Configuring Profile"
    ./ecs-cli-linux-amd64-latest configure profile --access-key $ACCESS_KEY --secret-key $SECRET_KEY --profile-name $PROFILE
}

function create_cluster() {
    echo "Creating Cluster"
    ./ecs-cli-linux-amd64-latest up --keypair $KEY --capability-iam --size 1 --vpc $VPC --subnets $SUBNET --instance-type $INSTANCE_TYPE --cluster-config $CONFIG --force
}

function deploy_docker() {
    echo "Deploying Docker"
    ./ecs-cli-linux-amd64-latest compose up --create-log-groups --cluster-config $CONFIG
}

function clean_up() {
    echo "Cleaning Up"
    ./ecs-cli-linux-amd64-latest down --force --cluster-config $CONFIG
}

function start() {
    ecs_configure

    create_cluster

    sleep 180

    deploy_docker

    sleep 60

    clean_up
}

start
