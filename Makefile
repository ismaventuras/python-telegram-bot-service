all: bot bot.service
.PHONY: all bot install uninstall
lib_dir=/usr/local/lib/bot
conf_dir=/usr/local/etc/bot
service_dir=/etc/systemd/system
venv=${lib_dir}/venv

install: $(service_dir) bot.service
	@echo Installing the service files...
	cp bot.service $(service_dir)
	chown root:root $(service_dir)/bot.service
	chmod 644 $(service_dir)/bot.service

	@echo Installing library files...
	mkdir -p $(lib_dir)
	cp bot.py $(lib_dir)
	chown root:root $(lib_dir)/*
	chmod 644 $(lib_dir)

	@echo Installing configuration files...
	mkdir -p $(conf_dir)
	cp bot.env $(conf_dir)
	chown root:root $(conf_dir)/*
	chmod 644 $(conf_dir)

	@echo Creating python virtual environment and installing packages...
	python3 -m venv $(venv)
	$(venv)/bin/pip3 install -r requirements.txt

	@echo Installation complete...
	@echo run 'systemctl start bot' to start service
	@echo run 'systemctl status bot' to view status

uninstall:
	-systemctl stop bot
	-systemctl disable bot
	-rm -r $(lib_dir)
	-rm -r $(conf_dir)
	-rm -r $(service_dir)/bot.service