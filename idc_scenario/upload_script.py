#!/usr/bin/env python3
"""
NetBox IDC Scenario - CSV Bulk Upload Script

이 스크립트는 CSV 파일을 읽어서 NetBox API를 통해 데이터를 일괄 업로드합니다.

사용법:
    python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN

의존성:
    pip install requests
"""

import argparse
import csv
import sys
import time
from pathlib import Path
from typing import Dict, List, Any

try:
    import requests
except ImportError:
    print("Error: 'requests' 라이브러리가 필요합니다.")
    print("설치: pip install requests")
    sys.exit(1)


class NetBoxUploader:
    """NetBox CSV 업로더"""

    # CSV 파일과 API 엔드포인트 매핑
    CSV_TO_ENDPOINT = {
        '01_sites.csv': 'dcim/sites',
        '02_manufacturers.csv': 'dcim/manufacturers',
        '03_device_roles.csv': 'dcim/device-roles',
        '04_device_types.csv': 'dcim/device-types',
        '05_locations.csv': 'dcim/locations',
        '06_racks.csv': 'dcim/racks',
        '07_devices_datacenter.csv': 'dcim/devices',
        '08_devices_test.csv': 'dcim/devices',
        '09_interfaces.csv': 'dcim/interfaces',
        '10_vlans.csv': 'ipam/vlans',
        '11_prefixes.csv': 'ipam/prefixes',
        '12_ip_addresses.csv': 'ipam/ip-addresses',
    }

    # 필드 변환 매핑 (CSV 필드명 -> API 필드명)
    FIELD_MAPPINGS = {
        'device_type': {'manufacturer': 'manufacturer', 'model': 'model'},
        'device': {'site': 'site', 'device_type': 'device_type', 'device_role': 'device_role'},
    }

    def __init__(self, base_url: str, token: str, csv_dir: Path):
        """
        Args:
            base_url: NetBox URL (예: http://localhost:8000)
            token: API 토큰
            csv_dir: CSV 파일이 있는 디렉토리
        """
        self.base_url = base_url.rstrip('/')
        self.api_url = f"{self.base_url}/api"
        self.headers = {
            'Authorization': f'Token {token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }
        self.csv_dir = csv_dir

        # 캐시: 이미 생성된 객체들을 저장 (중복 생성 방지)
        self.created_objects = {}

    def test_connection(self) -> bool:
        """NetBox 연결 테스트"""
        try:
            response = requests.get(f"{self.api_url}/status/", headers=self.headers, timeout=10)
            if response.status_code == 200:
                print(f"✓ NetBox 연결 성공: {self.base_url}")
                return True
            else:
                print(f"✗ NetBox 연결 실패: {response.status_code}")
                return False
        except requests.RequestException as e:
            print(f"✗ NetBox 연결 오류: {e}")
            return False

    def get_or_create_object(self, endpoint: str, lookup_fields: Dict[str, Any], data: Dict[str, Any]) -> Dict[str, Any]:
        """
        객체를 조회하거나 생성합니다.

        Args:
            endpoint: API 엔드포인트 (예: 'dcim/sites')
            lookup_fields: 조회용 필드 (예: {'slug': 'sms-pangyo'})
            data: 생성할 데이터

        Returns:
            생성되거나 조회된 객체
        """
        # 캐시 키 생성
        cache_key = f"{endpoint}:{':'.join(f'{k}={v}' for k, v in lookup_fields.items())}"

        if cache_key in self.created_objects:
            return self.created_objects[cache_key]

        # 1. 기존 객체 조회
        url = f"{self.api_url}/{endpoint}/"
        response = requests.get(url, headers=self.headers, params=lookup_fields, timeout=10)

        if response.status_code == 200:
            results = response.json().get('results', [])
            if results:
                obj = results[0]
                self.created_objects[cache_key] = obj
                return obj

        # 2. 객체 생성
        response = requests.post(url, headers=self.headers, json=data, timeout=10)

        if response.status_code in (200, 201):
            obj = response.json()
            self.created_objects[cache_key] = obj
            return obj
        else:
            raise Exception(f"객체 생성 실패: {response.status_code} - {response.text}")

    def resolve_foreign_key(self, endpoint: str, value: str, field_name: str = 'name') -> int:
        """
        ForeignKey 필드를 해결합니다 (이름 -> ID 변환).

        Args:
            endpoint: 참조 대상 엔드포인트
            value: 필드 값 (예: 'SMS Pangyo')
            field_name: 조회할 필드명 (기본: 'name')

        Returns:
            객체 ID
        """
        url = f"{self.api_url}/{endpoint}/"
        params = {field_name: value}

        response = requests.get(url, headers=self.headers, params=params, timeout=10)

        if response.status_code == 200:
            results = response.json().get('results', [])
            if results:
                return results[0]['id']

        raise Exception(f"{endpoint}에서 '{field_name}={value}' 객체를 찾을 수 없습니다.")

    def process_csv_row(self, endpoint: str, row: Dict[str, str]) -> Dict[str, Any]:
        """
        CSV 행 데이터를 API 데이터로 변환합니다.

        Args:
            endpoint: API 엔드포인트
            row: CSV 행 데이터

        Returns:
            API용 데이터
        """
        data = {}

        for key, value in row.items():
            if not value or value.strip() == '':
                continue

            # ForeignKey 해결 (site, manufacturer, device_type 등)
            if key in ('site', 'location', 'rack', 'manufacturer', 'device_role', 'device_type',
                       'vlan', 'region', 'parent', 'tenant', 'vrf'):
                if key == 'site':
                    data[key] = self.resolve_foreign_key('dcim/sites', value, 'name')
                elif key == 'location':
                    data[key] = self.resolve_foreign_key('dcim/locations', value, 'name')
                elif key == 'rack':
                    data[key] = self.resolve_foreign_key('dcim/racks', value, 'name')
                elif key == 'manufacturer':
                    data[key] = self.resolve_foreign_key('dcim/manufacturers', value, 'name')
                elif key == 'device_role':
                    data[key] = self.resolve_foreign_key('dcim/device-roles', value, 'name')
                elif key == 'device_type':
                    data[key] = self.resolve_foreign_key('dcim/device-types', value, 'model')
                elif key == 'vlan':
                    # VLAN은 vid로 조회
                    data[key] = self.resolve_foreign_key('ipam/vlans', value, 'vid')
                elif key == 'region':
                    data[key] = self.resolve_foreign_key('dcim/regions', value, 'name')
                elif key == 'tenant':
                    data[key] = self.resolve_foreign_key('tenancy/tenants', value, 'name')
                elif key == 'parent':
                    # parent는 같은 타입의 객체를 참조
                    if 'device-roles' in endpoint:
                        data[key] = self.resolve_foreign_key('dcim/device-roles', value, 'name')
                    elif 'locations' in endpoint:
                        data[key] = self.resolve_foreign_key('dcim/locations', value, 'name')

            # Boolean 변환
            elif key in ('is_full_depth', 'enabled', 'is_pool', 'desc_units', 'vm_role'):
                data[key] = value.lower() in ('true', '1', 'yes', 't')

            # Integer 변환
            elif key in ('u_height', 'position', 'vid', 'mtu', 'weight', 'max_weight',
                        'outer_width', 'outer_depth'):
                try:
                    data[key] = int(value)
                except ValueError:
                    data[key] = value

            # Float 변환
            elif key in ('latitude', 'longitude'):
                try:
                    data[key] = float(value)
                except ValueError:
                    data[key] = value

            # Tags 처리 (세미콜론으로 구분)
            elif key == 'tags':
                data[key] = [{'name': tag.strip()} for tag in value.split(';') if tag.strip()]

            else:
                data[key] = value

        return data

    def upload_csv_file(self, csv_filename: str, dry_run: bool = False) -> tuple[int, int]:
        """
        단일 CSV 파일을 업로드합니다.

        Args:
            csv_filename: CSV 파일명
            dry_run: True인 경우 실제 업로드 없이 검증만 수행

        Returns:
            (성공 수, 실패 수)
        """
        csv_path = self.csv_dir / csv_filename

        if not csv_path.exists():
            print(f"✗ 파일을 찾을 수 없습니다: {csv_path}")
            return 0, 0

        endpoint = self.CSV_TO_ENDPOINT.get(csv_filename)
        if not endpoint:
            print(f"✗ 알 수 없는 CSV 파일: {csv_filename}")
            return 0, 0

        print(f"\n{'[DRY RUN] ' if dry_run else ''}업로드 중: {csv_filename} -> {endpoint}")
        print("-" * 80)

        success_count = 0
        error_count = 0

        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)

            for idx, row in enumerate(reader, start=1):
                try:
                    # CSV 데이터를 API 데이터로 변환
                    data = self.process_csv_row(endpoint, row)

                    if not data:
                        continue

                    # 객체 이름 추출 (로깅용)
                    obj_name = data.get('name') or data.get('model') or data.get('address') or f"행 {idx}"

                    if dry_run:
                        print(f"  ✓ [{idx}] {obj_name} (검증 통과)")
                        success_count += 1
                    else:
                        # API 호출
                        url = f"{self.api_url}/{endpoint}/"
                        response = requests.post(url, headers=self.headers, json=data, timeout=10)

                        if response.status_code in (200, 201):
                            print(f"  ✓ [{idx}] {obj_name} (생성 성공)")
                            success_count += 1
                        else:
                            error_detail = response.json() if response.headers.get('content-type') == 'application/json' else response.text
                            print(f"  ✗ [{idx}] {obj_name} (실패: {response.status_code})")
                            print(f"      상세: {error_detail}")
                            error_count += 1

                    # API Rate Limiting 방지
                    time.sleep(0.1)

                except Exception as e:
                    print(f"  ✗ [{idx}] 오류: {e}")
                    error_count += 1

        print("-" * 80)
        print(f"결과: 성공 {success_count}, 실패 {error_count}")

        return success_count, error_count

    def upload_all(self, dry_run: bool = False) -> Dict[str, tuple[int, int]]:
        """
        모든 CSV 파일을 순서대로 업로드합니다.

        Args:
            dry_run: True인 경우 실제 업로드 없이 검증만 수행

        Returns:
            파일별 (성공 수, 실패 수) 딕셔너리
        """
        results = {}

        print(f"\n{'=' * 80}")
        print(f"NetBox IDC Scenario {'검증' if dry_run else '업로드'} 시작")
        print(f"{'=' * 80}")

        for csv_filename in sorted(self.CSV_TO_ENDPOINT.keys()):
            success, errors = self.upload_csv_file(csv_filename, dry_run=dry_run)
            results[csv_filename] = (success, errors)

        print(f"\n{'=' * 80}")
        print(f"{'검증' if dry_run else '업로드'} 완료")
        print(f"{'=' * 80}")

        total_success = sum(s for s, _ in results.values())
        total_errors = sum(e for _, e in results.values())

        print(f"\n총 결과:")
        print(f"  - 성공: {total_success}")
        print(f"  - 실패: {total_errors}")

        if total_errors > 0:
            print(f"\n⚠ {total_errors}개의 오류가 발생했습니다. 위 로그를 확인하세요.")
        else:
            print(f"\n✓ 모든 데이터가 성공적으로 {'검증' if dry_run else '업로드'}되었습니다!")

        return results


def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(
        description='NetBox IDC 시나리오 CSV 업로더',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
예시:
  # 연결 테스트
  python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN --test

  # Dry run (검증만)
  python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN --dry-run

  # 실제 업로드
  python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN

  # 특정 파일만 업로드
  python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN --file 01_sites.csv
        """
    )

    parser.add_argument('--url', required=True, help='NetBox URL (예: http://localhost:8000)')
    parser.add_argument('--token', required=True, help='NetBox API 토큰')
    parser.add_argument('--csv-dir', default='csv_templates', help='CSV 파일 디렉토리 (기본: csv_templates)')
    parser.add_argument('--file', help='업로드할 특정 CSV 파일 (지정하지 않으면 전체 업로드)')
    parser.add_argument('--dry-run', action='store_true', help='실제 업로드 없이 검증만 수행')
    parser.add_argument('--test', action='store_true', help='연결 테스트만 수행')

    args = parser.parse_args()

    # CSV 디렉토리 확인
    csv_dir = Path(__file__).parent / args.csv_dir
    if not csv_dir.exists():
        print(f"✗ CSV 디렉토리를 찾을 수 없습니다: {csv_dir}")
        sys.exit(1)

    # 업로더 초기화
    uploader = NetBoxUploader(args.url, args.token, csv_dir)

    # 연결 테스트
    if not uploader.test_connection():
        sys.exit(1)

    if args.test:
        print("✓ 연결 테스트 완료!")
        sys.exit(0)

    # 업로드 실행
    try:
        if args.file:
            # 특정 파일만 업로드
            uploader.upload_csv_file(args.file, dry_run=args.dry_run)
        else:
            # 전체 업로드
            uploader.upload_all(dry_run=args.dry_run)
    except KeyboardInterrupt:
        print("\n\n중단되었습니다.")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
