/**
 * Class for setting header for authorization purpose
 * Also having baseurl for restful apis
 */

import { HttpHeaders } from '@angular/common/http';

export class HeaderSetter {
    public baseUrl:string;
    constructor(){
        this.baseUrl="http://192.168.0.109:3000/client";
    }
   
    getHeader():any{
        let headers=new HttpHeaders({
            'Authorization':`Bearer ${localStorage.getItem("token")}`
          })
          let options={headers:headers};
          return options;
    }
}
