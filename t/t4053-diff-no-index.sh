test_expect_success 'git diff --no-index --exit-code' '
	git diff --no-index --exit-code a/1 non/git/a &&
	test_expect_code 1 git diff --no-index --exit-code a/1 a/2
'

test_expect_success 'diff --no-index normalizes mode: no changes' '
	echo foo >x &&
	cp x y &&
	git diff --no-index x y >out &&
	test_must_be_empty out
'

test_expect_success POSIXPERM 'diff --no-index normalizes mode: chmod +x' '
	chmod +x y &&
	cat >expected <<-\EOF &&
	diff --git a/x b/y
	old mode 100644
	new mode 100755
	EOF
	test_expect_code 1 git diff --no-index x y >actual &&
	test_cmp expected actual
'

test_expect_success POSIXPERM 'diff --no-index normalizes: mode not like git mode' '
	chmod 666 x &&
	chmod 777 y &&
	cat >expected <<-\EOF &&
	diff --git a/x b/y
	old mode 100644
	new mode 100755
	EOF
	test_expect_code 1 git diff --no-index x y >actual &&
	test_cmp expected actual
'

test_expect_success POSIXPERM,SYMLINKS 'diff --no-index normalizes: mode not like git mode (symlink)' '
	ln -s y z &&
	X_OID=$(git hash-object --stdin <x) &&
	Z_OID=$(printf y | git hash-object --stdin) &&
	cat >expected <<-EOF &&
	diff --git a/x b/x
	deleted file mode 100644
	index $X_OID..$ZERO_OID
	--- a/x
	+++ /dev/null
	@@ -1 +0,0 @@
	-foo
	diff --git a/z b/z
	new file mode 120000
	index $ZERO_OID..$Z_OID
	--- /dev/null
	+++ b/z
	@@ -0,0 +1 @@
	+y
	\ No newline at end of file
	EOF
	test_expect_code 1 git -c core.abbrev=no diff --no-index x z >actual &&
	test_cmp expected actual
'
