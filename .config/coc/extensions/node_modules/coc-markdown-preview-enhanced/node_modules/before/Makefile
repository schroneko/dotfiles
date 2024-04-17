
install: package.json
	@npm install --production

dev: package.json
	@npm install

test:
	@mocha -r should -R spec test

test-watch:
	@mocha -w -r should -R spec test

clean:
	rm -rf node_modules

.PHONY: test test-watch clean
