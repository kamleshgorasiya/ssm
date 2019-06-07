import { HttpHeaders } from '@angular/common/http';
export class Headersetter {
    public baseUrl:string;
    constructor(){
        this.baseUrl="http://192.168.0.109:3000/admin";
    }
    getHeader():any{
        let headers=new HttpHeaders({
            'Authorization':`Bearer ${localStorage.getItem("token")}`
          })
          let options={headers:headers};
          return options;
    }
}
