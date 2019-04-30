import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {

  constructor(private _authService:AuthService,private dataService:DataExchangeService,private _router:Router) { }
  user:any={};
  errorText:string;
  ngOnInit() {
  }

  registerUser(){
     this._authService.registerUser(this.user)
     .subscribe(
       res=>{
         
        localStorage.setItem("token",res.token);
        this._authService.getUser()
        .subscribe(
          res=>{
            this.dataService.changeUserName(res[0])
          },
          err=>{
            this.dataService.changeUserName("Profile");
          }
        )
        this._router.navigate(['']);
       },
       err=>{
         this.errorText=err.error;
       }
     )
  }
}
