IDL=idl

.PHONY: doc clean

doc:
	$(IDL) -e "mg_make_demos_docs"

clean:
	rm -rf api-docs
