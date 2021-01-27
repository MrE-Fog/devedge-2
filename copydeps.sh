#
# Populates the dependency directories with only what is required
#
NPM_DEPS_ROOT=node_modules/

# fonts
# font-awesome
mkdir -p assets/deps/font-awesome/css
mkdir -p assets/deps/font-awesome/fonts
cp ${NPM_DEPS_ROOT}/font-awesome/css/font-awesome.min.css assets/deps/font-awesome/css/
cp ${NPM_DEPS_ROOT}/font-awesome/css/font-awesome.css.map assets/deps/font-awesome/css/
cp ${NPM_DEPS_ROOT}/font-awesome/fonts/fontawesome-webfont* assets/deps/font-awesome/fonts/
# spoqahansans
mkdir -p assets/deps/spoqa-han-sans/css
mkdir -p assets/deps/spoqa-han-sans/Subset/SpoqaHanSansNeo
cp ${NPM_DEPS_ROOT}/spoqa-han-sans/css/SpoqaHanSans-kr.css assets/deps/spoqa-han-sans/css/
cp ${NPM_DEPS_ROOT}/spoqa-han-sans/Subset/SpoqaHanSansNeo/SpoqaHanSansNeo* assets/deps/spoqa-han-sans/Subset/SpoqaHanSansNeo/

# Nord theme
mkdir -p assets/deps/nord-highlightjs/dist
cp ${NPM_DEPS_ROOT}/nord-highlightjs/dist/nord.css assets/deps/nord-highlightjs/dist/
# highlight.js
mkdir -p assets/deps/highlight.js/lib
wget --directory-prefix assets/deps/highlight.js/ https://unpkg.com/@highlightjs/cdn-assets@10.5.0/highlight.min.js
