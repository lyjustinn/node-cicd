const app = require("./app");
require('dotenv').config();
let PORT = process.env.PORT || 3000;
let PORT = process.env.NODE_ENV === "production" ? 80 : PORT;

app.listen(PORT, () => {
    console.log('Server running on port ' + PORT);
});