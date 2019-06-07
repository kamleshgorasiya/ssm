import { TestBed,async,inject } from '@angular/core/testing';
import{HttpTestingController, HttpClientTestingModule} from '@angular/common/http/testing';
import { AddressService } from './address.service';
import { HeaderSetter } from '../data/header-setter';
import { Observable } from 'rxjs';
import { Address } from '../data/address';

describe('AddressService', () => {
  let service;
  beforeEach(() => TestBed.configureTestingModule({
    imports:[HttpClientTestingModule],
    providers:[HeaderSetter]
  }));

  it(`should create`, async(inject([HttpTestingController, AddressService],
    (httpClient: HttpTestingController, apiService: AddressService) => {
      expect(apiService).toBeTruthy();
  })));

  it('should return shipping regions',inject([AddressService],(service)=>{
   service.getShippingRegion()
   .subscribe(
     res=>{
       expect(res.length).toBeGreaterThan(0);
     }
   )
  }));
});
