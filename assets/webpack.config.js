const path = require("path");
const glob = require("glob-all");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const PurgecssPlugin = require("purgecss-webpack-plugin");

module.exports = (env, options) => {
  const devMode = options.mode !== "production";

  return {
    entry: {
      app: glob.sync("./vendor/**/*.js").concat(["./js/app.js"]),
    },
    output: {
      path: path.resolve(__dirname, "../priv/static/js"),
      filename: "[name].js",
      publicPath: "/js/",
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
          },
        },
        {
          test: /\.[s]?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            "css-loader",
            "sass-loader",
            "postcss-loader",
          ],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: "../css/app.css" }),
      new CopyWebpackPlugin({
        patterns: [{ from: "static/", to: "../" }],
      }),
    ].concat(
      devMode
        ? []
        : [
            new PurgecssPlugin({
              paths: glob.sync([
                "../**/*.html.leex",
                "../**/*.html.eex",
                "../**/views/**/*.ex",
                "../**/live/**/*.ex",
                "./js/**/*.js",
              ]),
              safelist: [/phx/, /topbar/],
            }),
          ]
    ),
    optimization: {
      minimizer: ["...", new CssMinimizerPlugin()],
    },
    devtool: devMode ? "source-map" : undefined,
  };
};
