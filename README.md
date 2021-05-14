# Magento 2 install script

Only for local development usage. Dont use it for production!

## Usage

1. env file
Create new .env file from dist
```
cp .env.dist .env
```
Set correct values to .env

2. Make install.sh executable
```
chmod +x install.sh 
```

3. Install
```
./install.sh
```
or, if need to log output
```
./install.sh > install_log.txt
```