# Ask user for confirmation to proceed. 
function askProceed() {
  echo "========================== Warning =============================="
  echo "This script will stop and remove all locally running containers, "
  echo "and remove all local chaincode images from all Fabric networks"
  echo "================================================================="
  read -p "Continue? [Y/n] " ans
  case "$ans" in
  y | Y | "")
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
    echo "invalid response"
    askProceed
    ;;
  esac
}

askProceed

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images dev* -q)
docker volume prune -f
docker network prune -f


