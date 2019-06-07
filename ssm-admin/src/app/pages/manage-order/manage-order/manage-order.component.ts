import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-manage-order',
  templateUrl: './manage-order.component.html',
  styleUrls: ['./manage-order.component.css']
})
export class ManageOrderComponent implements OnInit {

  constructor(private _authService:AuthService,
              private _router:Router) { }

  ngOnInit() {
        // if user not logged in,it will redirect to login page

        if(!this._authService.loggedIn()){
          this._router.navigate(['']);
        }
  }

}
