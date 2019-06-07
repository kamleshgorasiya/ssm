import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {


  errorText="";
  user:any={};

  constructor(private _authService:AuthService,
              private _router:Router
              ) { }

  ngOnInit() {

  }

  loginUser(){
  this._authService.loginUser(this.user)
    .subscribe(
      res=>{
        localStorage.setItem("token",res.token);
        this._router.navigate(['dashboard']);
      },
      err=>{
        this.errorText=err.error;
      }
    )
  }
}
