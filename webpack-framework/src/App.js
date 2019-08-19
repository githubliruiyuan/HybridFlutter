import {template} from 'lodash';

class App {
    constructor(id) {
        this.id = id;
    }

    init() {
        console.log('App::init()');
        const el = document.getElementById(this.id);
        const header = this.headerContent();
        const about = this.aboutContent();
        const links = this.linksContent();

        el.innerHTML = header + about + links;
    }

    headerContent() {
        const hello = "Hello Webpack";
        return template('<h1><%- hello %></h1><h5>v2.0.0</h5>')({hello});
    }

    aboutContent() {
        const content = "<em>webpack-helloworld</em> is a demo app made with Webpack 4 featuring a simple configuration file including Babel and Sass.";

        return template('<h2>About</h2><div><%= content %></div>')({content});
    }

    linksContent() {
        const links = {
            'Webpack Documentation': 'https://webpack.js.org/concepts/',
            'Awesome Webpack': 'https://github.com/webpack-contrib/awesome-webpack',
            'Babel.io': 'https://babeljs.io/'
        };

        return template('<h2>Links</h2><div><ul><% _.forEach(links, function(link, title) { %><li><a href="<%= link %>"><%= title %></a></li><% }); %></ul></div>')({ links });
    }
}

export default App;
