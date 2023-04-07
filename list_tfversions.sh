if test $# -lt 1 
then
    echo "Usage: list_tfversions.sh -d <directory containing tfcloud> [-s --nospryker] [-a --noaldi] [-tg --terragrunt] [-tf --terraform] "
    exit 1
fi

  while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -a|--noaldi)
        NOALDI="TRUE"
        ;;
      -s|--nospryker)
        NOSPRYKER="TRUE"
        ;;        
      -tg|--terragrunt)
        TG="TRUE"
        ;;                
      -tf|--terraform)
        TF="TRUE"
        ;;           
      -d|--dir)
        DIR="$2"
        ;;
    esac
    shift
  done


CURRENTDIR=`pwd`
echo "environment;version"
cd $DIR
CNT=0
for env in `find . -mindepth 2 -maxdepth 2 -type d | grep -vP 'ansible|conf.d|modules|templates|tools' | sort -h | sed 's#\./##'`; do   
    if [[ $env == aldi/* ]]  && [[ $NOALDI == "TRUE" ]]; then
        continue
    fi
    if [[ $env == spryker/* ]] && [[ $NOSPRYKER == "TRUE" ]]; then
        continue
    fi
    if [[ $env == aop/* ]] && [[ $NOSPRYKER == "TRUE" ]]; then
        continue
    fi
    if [[ $TG == "TRUE" ]]; then      
      if [ -f $env/config/common/spryker.hcl ]; then
        cd $env
        echo -e "$env;\"$(grep -r released_version.*\=.* | dos2unix | sed '/#/d;s/^.*released_version.*=.*\"\(.*\)\".*$/\1/')\"";
        cd ../../;
        CNT=$((CNT+1))
      fi
    fi
    if [[ $TF == "TRUE" ]]; then      
      test -f $env/*network*/main.tf || continue; 
      cd $env; 
      echo -e "$env;\"$(grep -r ref=v */*tf | dos2unix | sed '/#/d;s/^.*ref=v\(.*\)"/\1/' | sort -hu | sed ':a;N;$!ba;s#\n# ; #g')\"";    
      cd ../../;
      CNT=$((CNT+1))
    fi
done
cd $CURRENTDIR
echo $CNT