const app = require("./app");
require('dotenv').config();
let PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log('Server running on port ' + PORT);
});