sudo apt-get update
sudo apt-get install libopenblas-base 
sudo apt-get install littler
sudo apt-get install libssl-dev libcurl4-openssl-dev libxml2-dev

# Add CRAN source
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -

sudo apt-get -y install r-base r-base-dev
sudo R --no-save < r/install_dependencies.R

mkdir data_out
mkdir logs