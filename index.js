const app = require("./app");
require('dotenv').config();
let PORT = process.env.PORT || 3000;
let PORT = process.env.NODE_ENV === "development" ||  process.env.NODE_ENV === "test" ?  PORT : 80;

app.listen(PORT, () => {
    console.log('Server running on port ' + PORT);
});